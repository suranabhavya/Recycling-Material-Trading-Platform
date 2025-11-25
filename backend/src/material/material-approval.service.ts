import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MaterialStatus } from '@prisma/client';

@Injectable()
export class MaterialApprovalService {
  constructor(private prisma: PrismaService) {}

  async getInitialApprovalLevel(creatorId: string): Promise<number | null> {
    const creator = await this.prisma.user.findUnique({
      where: { id: creatorId },
      include: {
        roleTemplate: true,
        company: {
          include: {
            roleTemplates: {
              orderBy: { level: 'asc' },
            },
          },
        },
      },
    });

    if (!creator || !creator.roleTemplate || !creator.company) {
      throw new NotFoundException('User or role template not found');
    }

    const creatorLevel = creator.roleTemplate.level;

    for (const role of creator.company.roleTemplates) {
      if (role.level < creatorLevel && role.requiresApproval) {
        return role.level;
      }
    }

    return null;
  }

  async getApprovalChainLevels(creatorId: string): Promise<number[]> {
    const creator = await this.prisma.user.findUnique({
      where: { id: creatorId },
      include: {
        roleTemplate: true,
        company: {
          include: {
            roleTemplates: {
              orderBy: { level: 'asc' },
            },
          },
        },
      },
    });

    if (!creator || !creator.roleTemplate || !creator.company) {
      return [];
    }

    const approvalLevels: number[] = [];
    const creatorLevel = creator.roleTemplate.level;

    for (const role of creator.company.roleTemplates) {
      if (role.level < creatorLevel && role.requiresApproval) {
        approvalLevels.push(role.level);
      }
    }

    return approvalLevels;
  }

  async approveMaterial(materialId: string, approverId: string) {
    const material = await this.prisma.material.findUnique({
      where: { id: materialId },
      include: {
        creator: {
          include: { roleTemplate: true },
        },
        company: {
          include: {
            roleTemplates: {
              orderBy: { level: 'asc' },
            },
          },
        },
      },
    });

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    const approver = await this.prisma.user.findUnique({
      where: { id: approverId },
      include: { roleTemplate: true },
    });

    if (!approver || !approver.roleTemplate) {
      throw new ForbiddenException('Approver role not found');
    }

    if (approver.companyId !== material.companyId) {
      throw new ForbiddenException('Cannot approve materials from another company');
    }

    if (material.currentApprovalLevel !== approver.roleTemplate.level) {
      throw new ForbiddenException('You are not authorized to approve this material at this level');
    }

    const approvalChain = Array.isArray(material.approvalChain)
      ? material.approvalChain
      : [];

    approvalChain.push({
      level: approver.roleTemplate.level,
      userId: approverId,
      userName: approver.name,
      action: 'approved',
      timestamp: new Date().toISOString(),
    });

    const nextLevel = await this.getNextApprovalLevel(
      material.creatorId,
      approver.roleTemplate.level,
    );

    const updatedMaterial = await this.prisma.material.update({
      where: { id: materialId },
      data: {
        currentApprovalLevel: nextLevel,
        status: nextLevel === null ? MaterialStatus.APPROVED : MaterialStatus.PENDING,
        approvalChain: approvalChain,
        lastApproverId: approverId,
        lastApprovedAt: new Date(),
      },
      include: {
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        lastApprover: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    return updatedMaterial;
  }

  async rejectMaterial(materialId: string, approverId: string, reason: string) {
    const material = await this.prisma.material.findUnique({
      where: { id: materialId },
    });

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    const approver = await this.prisma.user.findUnique({
      where: { id: approverId },
      include: { roleTemplate: true },
    });

    if (!approver || !approver.roleTemplate) {
      throw new ForbiddenException('Approver role not found');
    }

    if (approver.companyId !== material.companyId) {
      throw new ForbiddenException('Cannot reject materials from another company');
    }

    if (material.currentApprovalLevel !== approver.roleTemplate.level) {
      throw new ForbiddenException('You are not authorized to reject this material at this level');
    }

    const approvalChain = Array.isArray(material.approvalChain)
      ? material.approvalChain
      : [];

    approvalChain.push({
      level: approver.roleTemplate.level,
      userId: approverId,
      userName: approver.name,
      action: 'rejected',
      timestamp: new Date().toISOString(),
      reason,
    });

    const updatedMaterial = await this.prisma.material.update({
      where: { id: materialId },
      data: {
        status: MaterialStatus.REJECTED,
        currentApprovalLevel: null,
        approvalChain: approvalChain,
        rejectionReason: reason,
        lastApproverId: approverId,
        lastApprovedAt: new Date(),
      },
      include: {
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        lastApprover: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    return updatedMaterial;
  }

  async getPendingApprovals(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { roleTemplate: true },
    });

    if (!user || !user.roleTemplate || !user.companyId) {
      throw new NotFoundException('User or role not found');
    }

    return this.prisma.material.findMany({
      where: {
        companyId: user.companyId,
        currentApprovalLevel: user.roleTemplate.level,
        status: MaterialStatus.PENDING,
      },
      include: {
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
            roleTemplate: {
              select: {
                name: true,
                level: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async canApprove(userId: string, materialId: string): Promise<boolean> {
    const material = await this.prisma.material.findUnique({
      where: { id: materialId },
    });

    if (!material) {
      return false;
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { roleTemplate: true },
    });

    if (!user || !user.roleTemplate) {
      return false;
    }

    if (user.companyId !== material.companyId) {
      return false;
    }

    return material.currentApprovalLevel === user.roleTemplate.level;
  }

  private async getNextApprovalLevel(
    creatorId: string,
    currentLevel: number,
  ): Promise<number | null> {
    const creator = await this.prisma.user.findUnique({
      where: { id: creatorId },
      include: {
        company: {
          include: {
            roleTemplates: {
              where: {
                level: { lt: currentLevel },
                requiresApproval: true,
              },
              orderBy: { level: 'desc' },
              take: 1,
            },
          },
        },
      },
    });

    if (!creator || !creator.company || creator.company.roleTemplates.length === 0) {
      return null;
    }

    return creator.company.roleTemplates[0].level;
  }
}

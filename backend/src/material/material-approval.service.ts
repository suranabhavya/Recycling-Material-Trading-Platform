import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MaterialStatus, ApprovalStatus } from '@prisma/client';

@Injectable()
export class MaterialApprovalService {
  constructor(private prisma: PrismaService) {}

  /**
   * Recursively get all subordinate IDs for SIMPLE hierarchy mode
   */
  private async getAllSubordinateIds(userId: string): Promise<string[]> {
    const subordinates = await this.prisma.user.findMany({
      where: { managerId: userId },
      select: { id: true },
    });

    const subordinateIds = subordinates.map(s => s.id);

    // Recursively get subordinates of subordinates
    for (const subordinate of subordinates) {
      const nestedIds = await this.getAllSubordinateIds(subordinate.id);
      subordinateIds.push(...nestedIds);
    }

    return subordinateIds;
  }

  /**
   * Recursively get all managed org unit IDs for ADVANCED hierarchy mode
   */
  private async getManagedOrgUnitIds(orgUnitId: string): Promise<string[]> {
    const orgUnit = await this.prisma.organizationalUnit.findUnique({
      where: { id: orgUnitId },
      include: { children: true },
    });

    if (!orgUnit) {
      return [];
    }

    const orgUnitIds = [orgUnitId];

    // Recursively get child org units
    for (const child of orgUnit.children) {
      const nestedIds = await this.getManagedOrgUnitIds(child.id);
      orgUnitIds.push(...nestedIds);
    }

    return orgUnitIds;
  }

  async approveMaterial(materialId: string, approverId: string) {
    const material = await this.prisma.material.findUnique({
      where: { id: materialId },
      include: {
        approvalHistory: {
          orderBy: { approvedAt: 'desc' },
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

    // Calculate time taken from last action or material creation
    const lastAction = material.approvalHistory.length > 0
      ? material.approvalHistory[0]
      : null;

    const timeTakenMs = lastAction
      ? Date.now() - lastAction.approvedAt.getTime()
      : Date.now() - material.createdAt.getTime();

    // Find next level from frozen requiredApprovalLevels chain
    const currentIndex = material.requiredApprovalLevels.indexOf(material.currentApprovalLevel!);
    const nextLevel = currentIndex >= 0 && currentIndex < material.requiredApprovalLevels.length - 1
      ? material.requiredApprovalLevels[currentIndex + 1]
      : null;

    // Create approval history entry
    await this.prisma.approvalHistory.create({
      data: {
        materialId,
        level: approver.roleTemplate.level,
        userId: approverId,
        action: ApprovalStatus.APPROVED,
        timeTakenMs,
      },
    });

    // Update material
    const updatedMaterial = await this.prisma.material.update({
      where: { id: materialId },
      data: {
        currentApprovalLevel: nextLevel,
        status: nextLevel === null ? MaterialStatus.APPROVED : MaterialStatus.PENDING,
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
        approvalHistory: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
          orderBy: {
            approvedAt: 'desc',
          },
        },
      },
    });

    return updatedMaterial;
  }

  async rejectMaterial(materialId: string, approverId: string, reason: string) {
    const material = await this.prisma.material.findUnique({
      where: { id: materialId },
      include: {
        approvalHistory: {
          orderBy: { approvedAt: 'desc' },
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
      throw new ForbiddenException('Cannot reject materials from another company');
    }

    if (material.currentApprovalLevel !== approver.roleTemplate.level) {
      throw new ForbiddenException('You are not authorized to reject this material at this level');
    }

    // Calculate time taken from last action or material creation
    const lastAction = material.approvalHistory.length > 0
      ? material.approvalHistory[0]
      : null;

    const timeTakenMs = lastAction
      ? Date.now() - lastAction.approvedAt.getTime()
      : Date.now() - material.createdAt.getTime();

    // Create rejection history entry
    await this.prisma.approvalHistory.create({
      data: {
        materialId,
        level: approver.roleTemplate.level,
        userId: approverId,
        action: ApprovalStatus.REJECTED,
        comments: reason,
        timeTakenMs,
      },
    });

    // Update material
    const updatedMaterial = await this.prisma.material.update({
      where: { id: materialId },
      data: {
        status: MaterialStatus.REJECTED,
        currentApprovalLevel: null,
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
        approvalHistory: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
          orderBy: {
            approvedAt: 'desc',
          },
        },
      },
    });

    return updatedMaterial;
  }

  async getPendingApprovals(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        roleTemplate: true,
        company: true,
      },
    });

    if (!user || !user.roleTemplate || !user.companyId || !user.company) {
      throw new NotFoundException('User or role not found');
    }

    // Build hierarchy-aware filter based on company mode
    // For SIMPLE mode: Show materials from subordinates in the hierarchy
    // For ADVANCED mode: Show materials from managed org units
    let whereConditions: any = {
      companyId: user.companyId,
      currentApprovalLevel: user.roleTemplate.level,
      status: MaterialStatus.PENDING,
    };

    if (user.company.hierarchyMode === 'SIMPLE') {
      // Get all subordinates (people who report to this user, directly or indirectly)
      const subordinateIds = await this.getAllSubordinateIds(userId);

      if (subordinateIds.length > 0) {
        // Show materials where creator is a subordinate
        whereConditions.creatorId = { in: subordinateIds };
      } else {
        // If no subordinates, don't show any materials in SIMPLE mode
        // (unless they're direct reports, which we check via managerId)
        whereConditions.creator = { managerId: userId };
      }
    } else if (user.company.hierarchyMode === 'ADVANCED' && user.orgUnitId) {
      // Get all managed org units (this unit and all child units)
      const managedOrgUnitIds = await this.getManagedOrgUnitIds(user.orgUnitId);

      if (managedOrgUnitIds.length > 0) {
        // Show materials from creators in managed org units
        whereConditions.creatorOrgUnitId = { in: managedOrgUnitIds };
      }
    }

    return this.prisma.material.findMany({
      where: whereConditions,
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
        approvalHistory: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
          orderBy: {
            approvedAt: 'desc',
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
}

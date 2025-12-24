import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMaterialDto } from './dto/create-material.dto';
import { ApproveMaterialDto } from './dto/approve-material.dto';
import { MaterialStatus, ApprovalAction, JoinRequestStatus } from '@prisma/client';

@Injectable()
export class MaterialService {
  constructor(private prisma: PrismaService) {}

  // =====================================================
  // MATERIAL CRUD
  // =====================================================

  async create(dto: CreateMaterialDto, creatorId: string) {
    const creator = await this.prisma.user.findUnique({
      where: { id: creatorId },
      include: {
        directManager: true,
      },
    });

    if (!creator || !creator.companyId) {
      throw new BadRequestException('User must be part of a company to create materials');
    }

    if (creator.joinRequestStatus !== JoinRequestStatus.APPROVED) {
      throw new BadRequestException('User must be approved to create materials');
    }

    // Determine if approval is required
    const requiresApproval = dto.requiresApproval ?? (creator.directManagerId ? true : false);

    return this.prisma.material.create({
      data: {
        name: dto.name,
        description: dto.description,
        quantity: dto.quantity,
        unit: dto.unit,
        price: dto.price,
        images: dto.images || [],
        creatorId,
        companyId: creator.companyId,
        creatorManagerId: creator.directManagerId,
        requiresApproval,
        status: requiresApproval ? MaterialStatus.PENDING : MaterialStatus.APPROVED,
        finalizedAt: requiresApproval ? null : new Date(),
      },
      include: {
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  async findAll(companyId: string, userId?: string) {
    return this.prisma.material.findMany({
      where: {
        companyId,
      },
      include: {
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        approvals: {
          include: {
            approver: {
              select: {
                id: true,
                name: true,
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

  async findOne(id: string) {
    const material = await this.prisma.material.findUnique({
      where: { id },
      include: {
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
            directManager: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
        approvals: {
          include: {
            approver: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
          orderBy: {
            approvedAt: 'asc',
          },
        },
      },
    });

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    return material;
  }

  async getPendingApprovalsForUser(userId: string) {
    // Get materials where:
    // 1. Material is PENDING
    // 2. User is the direct manager of the creator
    // 3. Material hasn't been approved/rejected by this user yet

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        directReports: {
          select: { id: true },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const directReportIds = user.directReports.map(u => u.id);

    const pendingMaterials = await this.prisma.material.findMany({
      where: {
        status: MaterialStatus.PENDING,
        creatorId: { in: directReportIds },
        approvals: {
          none: {
            approverId: userId,
          },
        },
      },
      include: {
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        approvals: {
          include: {
            approver: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'asc',
      },
    });

    return pendingMaterials;
  }

  // =====================================================
  // APPROVAL FLOW
  // =====================================================

  async approveMaterial(materialId: string, approverId: string, dto: ApproveMaterialDto) {
    const material = await this.prisma.material.findUnique({
      where: { id: materialId },
      include: {
        creator: {
          include: {
            directManager: true,
          },
        },
        approvals: true,
      },
    });

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    if (material.status !== MaterialStatus.PENDING) {
      throw new BadRequestException('Material is not pending approval');
    }

    const approver = await this.prisma.user.findUnique({
      where: { id: approverId },
      include: {
        directReports: true,
      },
    });

    if (!approver) {
      throw new NotFoundException('Approver not found');
    }

    // Verify approver is the direct manager of the creator
    if (material.creatorManagerId !== approverId) {
      throw new ForbiddenException('You are not authorized to approve this material');
    }

    // Check if already approved/rejected by this user
    const existingApproval = material.approvals.find(a => a.approverId === approverId);
    if (existingApproval) {
      throw new BadRequestException('You have already acted on this material');
    }

    // Create approval record
    await this.prisma.materialApproval.create({
      data: {
        materialId,
        approverId,
        action: dto.action,
        comments: dto.comments,
      },
    });

    // Update material status
    if (dto.action === ApprovalAction.REJECTED) {
      await this.prisma.material.update({
        where: { id: materialId },
        data: {
          status: MaterialStatus.REJECTED,
          rejectionReason: dto.comments,
          finalizedAt: new Date(),
        },
      });

      return { message: 'Material rejected', status: MaterialStatus.REJECTED };
    }

    // If approved by direct manager, check if there's a manager above
    if (approver.directManagerId) {
      // There's a manager above - update creatorManagerId to next level
      await this.prisma.material.update({
        where: { id: materialId },
        data: {
          creatorManagerId: approver.directManagerId,
        },
      });

      return {
        message: 'Material approved, sent to next level',
        status: MaterialStatus.PENDING,
        nextApprover: approver.directManagerId,
      };
    } else {
      // This is the final approver
      await this.prisma.material.update({
        where: { id: materialId },
        data: {
          status: MaterialStatus.APPROVED,
          finalizedAt: new Date(),
        },
      });

      return { message: 'Material fully approved', status: MaterialStatus.APPROVED };
    }
  }

  async delete(id: string, userId: string) {
    const material = await this.prisma.material.findUnique({
      where: { id },
    });

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    // Only creator or company owner can delete
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const isCreator = material.creatorId === userId;
    const isOwner = user.userType === 'OWNER' && user.companyId === material.companyId;

    if (!isCreator && !isOwner) {
      throw new ForbiddenException('Only the creator or company owner can delete this material');
    }

    await this.prisma.material.delete({
      where: { id },
    });

    return { message: 'Material deleted successfully' };
  }
}

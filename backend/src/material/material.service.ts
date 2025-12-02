import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMaterialDto } from './dto/create-material.dto';
import { UpdateMaterialDto } from './dto/update-material.dto';
import { MaterialApprovalService } from './material-approval.service';
import { MaterialStatus } from '@prisma/client';

@Injectable()
export class MaterialService {
  constructor(
    private prisma: PrismaService,
    private approvalService: MaterialApprovalService,
  ) {}

  async create(userId: string, createMaterialDto: CreateMaterialDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        company: {
          include: {
            roleTemplates: {
              orderBy: { level: 'asc' },
            },
          },
        },
        roleTemplate: true
      },
    });

    if (!user || !user.companyId || !user.company) {
      throw new ForbiddenException('You must be part of a company to create materials');
    }

    if (user.companyApprovalStatus !== 'APPROVED') {
      throw new ForbiddenException('Your company membership must be approved first');
    }

    if (!user.roleTemplate) {
      throw new ForbiddenException('You must have a role assigned to create materials');
    }

    // Calculate required approval levels (snapshot)
    const requiredLevels: number[] = [];
    for (const role of user.company.roleTemplates) {
      if (role.level < user.roleTemplate.level && role.requiresApproval) {
        requiredLevels.push(role.level);
      }
    }

    const status = requiredLevels.length === 0
      ? MaterialStatus.APPROVED
      : MaterialStatus.PENDING;

    const currentApprovalLevel = requiredLevels.length > 0 ? requiredLevels[0] : null;

    return this.prisma.material.create({
      data: {
        ...createMaterialDto,
        creatorId: userId,
        companyId: user.companyId,
        creatorManagerId: user.managerId,
        creatorOrgUnitId: user.orgUnitId,
        requiredApprovalLevels: requiredLevels,
        status,
        currentApprovalLevel: currentApprovalLevel,
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
        company: {
          select: {
            id: true,
            name: true,
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
  }

  async findAll(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || !user.companyId) {
      return [];
    }

    return this.prisma.material.findMany({
      where: {
        companyId: user.companyId,
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

  async findMyMaterials(userId: string) {
    return this.prisma.material.findMany({
      where: {
        creatorId: userId,
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
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findOne(id: string, userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    const material = await this.prisma.material.findUnique({
      where: { id },
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
        company: {
          select: {
            id: true,
            name: true,
          },
        },
        lastApprover: {
          select: {
            id: true,
            name: true,
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

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    if (material.companyId !== user?.companyId) {
      throw new ForbiddenException('You can only view materials from your company');
    }

    return material;
  }

  async update(id: string, userId: string, updateMaterialDto: UpdateMaterialDto) {
    const material = await this.prisma.material.findUnique({
      where: { id },
    });

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    if (material.creatorId !== userId) {
      throw new ForbiddenException('You can only update your own materials');
    }

    if (material.status !== MaterialStatus.PENDING) {
      throw new ForbiddenException('Cannot update material that is already approved or rejected');
    }

    return this.prisma.material.update({
      where: { id },
      data: updateMaterialDto,
      include: {
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        company: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });
  }

  async remove(id: string, userId: string) {
    const material = await this.prisma.material.findUnique({
      where: { id },
      include: {
        creator: {
          include: { roleTemplate: true },
        },
      },
    });

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { roleTemplate: true },
    });

    const isCreator = material.creatorId === userId;
    const isAdmin = user?.roleTemplate?.level === 1;

    if (!isCreator && !isAdmin) {
      throw new ForbiddenException('You can only delete your own materials or be an admin');
    }

    await this.prisma.material.delete({
      where: { id },
    });

    return { message: 'Material deleted successfully' };
  }

  async getInventory(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || !user.companyId) {
      return [];
    }

    return this.prisma.material.findMany({
      where: {
        companyId: user.companyId,
        status: MaterialStatus.APPROVED,
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
      orderBy: {
        lastApprovedAt: 'desc',
      },
    });
  }
}

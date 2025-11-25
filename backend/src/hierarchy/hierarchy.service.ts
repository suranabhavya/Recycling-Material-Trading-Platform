import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateRoleTemplateDto } from './dto/create-role-template.dto';
import { UpdateRoleTemplateDto } from './dto/update-role-template.dto';
import { CreateOrgUnitDto } from './dto/create-org-unit.dto';
import { UpdateOrgUnitDto } from './dto/update-org-unit.dto';

@Injectable()
export class HierarchyService {
  constructor(private prisma: PrismaService) {}

  async createRoleTemplate(companyId: string, dto: CreateRoleTemplateDto) {
    const existing = await this.prisma.roleTemplate.findUnique({
      where: { companyId_level: { companyId, level: dto.level } },
    });

    if (existing) {
      throw new BadRequestException(`Role at level ${dto.level} already exists`);
    }

    return this.prisma.roleTemplate.create({
      data: {
        ...dto,
        companyId,
      },
    });
  }

  async getRoleTemplates(companyId: string) {
    return this.prisma.roleTemplate.findMany({
      where: { companyId },
      orderBy: { level: 'asc' },
      include: {
        _count: {
          select: { users: true },
        },
      },
    });
  }

  async getRoleTemplate(id: string) {
    const role = await this.prisma.roleTemplate.findUnique({
      where: { id },
      include: {
        _count: {
          select: { users: true },
        },
      },
    });

    if (!role) {
      throw new NotFoundException('Role template not found');
    }

    return role;
  }

  async updateRoleTemplate(id: string, dto: UpdateRoleTemplateDto) {
    await this.getRoleTemplate(id);

    return this.prisma.roleTemplate.update({
      where: { id },
      data: dto,
    });
  }

  async deleteRoleTemplate(id: string) {
    const role = await this.getRoleTemplate(id);

    const userCount = await this.prisma.user.count({
      where: { roleTemplateId: id },
    });

    if (userCount > 0) {
      throw new BadRequestException('Cannot delete role template with assigned users');
    }

    return this.prisma.roleTemplate.delete({
      where: { id },
    });
  }

  async createOrgUnit(companyId: string, dto: CreateOrgUnitDto) {
    if (dto.parentId) {
      const parent = await this.prisma.organizationalUnit.findUnique({
        where: { id: dto.parentId },
      });

      if (!parent || parent.companyId !== companyId) {
        throw new BadRequestException('Invalid parent unit');
      }
    }

    return this.prisma.organizationalUnit.create({
      data: {
        ...dto,
        companyId,
      },
    });
  }

  async getOrgUnits(companyId: string) {
    return this.prisma.organizationalUnit.findMany({
      where: { companyId },
      include: {
        children: {
          include: {
            _count: {
              select: { users: true },
            },
          },
        },
        _count: {
          select: { users: true },
        },
      },
    });
  }

  async getOrgTree(companyId: string) {
    const rootUnits = await this.prisma.organizationalUnit.findMany({
      where: {
        companyId,
        parentId: null,
      },
      include: {
        children: {
          include: {
            children: {
              include: {
                children: true,
              },
            },
          },
        },
      },
    });

    return rootUnits;
  }

  async getOrgUnit(id: string) {
    const unit = await this.prisma.organizationalUnit.findUnique({
      where: { id },
      include: {
        parent: true,
        children: true,
        users: {
          select: {
            id: true,
            name: true,
            email: true,
            isOrgUnitHead: true,
          },
        },
        _count: {
          select: { users: true },
        },
      },
    });

    if (!unit) {
      throw new NotFoundException('Organizational unit not found');
    }

    return unit;
  }

  async updateOrgUnit(id: string, dto: UpdateOrgUnitDto) {
    await this.getOrgUnit(id);

    if (dto.parentId) {
      if (dto.parentId === id) {
        throw new BadRequestException('Unit cannot be its own parent');
      }

      const parent = await this.prisma.organizationalUnit.findUnique({
        where: { id: dto.parentId },
      });

      if (!parent) {
        throw new BadRequestException('Invalid parent unit');
      }
    }

    return this.prisma.organizationalUnit.update({
      where: { id },
      data: dto,
    });
  }

  async deleteOrgUnit(id: string) {
    const unit = await this.getOrgUnit(id);

    if (unit._count.users > 0) {
      throw new BadRequestException('Cannot delete unit with assigned users');
    }

    const childCount = await this.prisma.organizationalUnit.count({
      where: { parentId: id },
    });

    if (childCount > 0) {
      throw new BadRequestException('Cannot delete unit with child units');
    }

    return this.prisma.organizationalUnit.delete({
      where: { id },
    });
  }

  async getApprovalChainLevels(userId: string): Promise<number[]> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
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

    if (!user || !user.roleTemplate || !user.company) {
      return [];
    }

    const approvalLevels: number[] = [];
    const userLevel = user.roleTemplate.level;

    for (const role of user.company.roleTemplates) {
      if (role.level < userLevel && role.requiresApproval) {
        approvalLevels.push(role.level);
      }
    }

    return approvalLevels;
  }

  async getNextApprovalLevel(userId: string): Promise<number | null> {
    const approvalLevels = await this.getApprovalChainLevels(userId);
    return approvalLevels.length > 0 ? approvalLevels[0] : null;
  }
}

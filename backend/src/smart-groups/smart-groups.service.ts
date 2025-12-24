import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSmartGroupDto } from './dto/create-smart-group.dto';
import { AddMemberDto } from './dto/add-member.dto';
import { UserType, JoinRequestStatus } from '@prisma/client';

@Injectable()
export class SmartGroupsService {
  constructor(private prisma: PrismaService) {}

  // =====================================================
  // SMART GROUP CRUD
  // =====================================================

  async create(companyId: string, dto: CreateSmartGroupDto, creatorId: string) {
    // Verify creator is Owner or Admin
    await this.ensureOwnerOrAdmin(creatorId, companyId);

    // Check for duplicate name
    const existing = await this.prisma.smartGroup.findUnique({
      where: {
        companyId_name: {
          companyId,
          name: dto.name,
        },
      },
    });

    if (existing) {
      throw new ConflictException('Smart group with this name already exists');
    }

    const smartGroup = await this.prisma.smartGroup.create({
      data: {
        companyId,
        name: dto.name,
        description: dto.description,
        criteria: dto.criteria || undefined,
        isManual: dto.isManual || false,
      },
    });

    // If automatic (criteria-based), auto-assign members
    if (!smartGroup.isManual && smartGroup.criteria) {
      await this.autoAssignMembers(smartGroup.id);
    }

    return smartGroup;
  }

  async findAll(companyId: string) {
    return this.prisma.smartGroup.findMany({
      where: { companyId },
      include: {
        _count: {
          select: {
            members: true,
          },
        },
      },
      orderBy: {
        name: 'asc',
      },
    });
  }

  async findOne(id: string) {
    const smartGroup = await this.prisma.smartGroup.findUnique({
      where: { id },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
                userType: true,
                role: {
                  select: {
                    id: true,
                    name: true,
                  },
                },
                directManager: {
                  select: {
                    id: true,
                    name: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    if (!smartGroup) {
      throw new NotFoundException('Smart group not found');
    }

    return smartGroup;
  }

  async update(id: string, dto: CreateSmartGroupDto, updaterId: string) {
    const smartGroup = await this.prisma.smartGroup.findUnique({
      where: { id },
    });

    if (!smartGroup) {
      throw new NotFoundException('Smart group not found');
    }

    // Verify updater is Owner or Admin
    await this.ensureOwnerOrAdmin(updaterId, smartGroup.companyId);

    const updated = await this.prisma.smartGroup.update({
      where: { id },
      data: {
        name: dto.name,
        description: dto.description,
        criteria: dto.criteria,
        isManual: dto.isManual,
      },
    });

    // Re-calculate auto-assignment if criteria changed
    if (!updated.isManual && updated.criteria) {
      await this.refreshAutoAssignments(id);
    }

    return updated;
  }

  async delete(id: string, deleterId: string) {
    const smartGroup = await this.prisma.smartGroup.findUnique({
      where: { id },
    });

    if (!smartGroup) {
      throw new NotFoundException('Smart group not found');
    }

    // Verify deleter is Owner or Admin
    await this.ensureOwnerOrAdmin(deleterId, smartGroup.companyId);

    await this.prisma.smartGroup.delete({
      where: { id },
    });

    return { message: 'Smart group deleted successfully' };
  }

  // =====================================================
  // MEMBER MANAGEMENT
  // =====================================================

  async addMember(smartGroupId: string, dto: AddMemberDto, adderId: string) {
    const smartGroup = await this.prisma.smartGroup.findUnique({
      where: { id: smartGroupId },
    });

    if (!smartGroup) {
      throw new NotFoundException('Smart group not found');
    }

    if (!smartGroup.isManual) {
      throw new BadRequestException('Cannot manually add members to automatic smart groups');
    }

    // Verify adder is Owner or Admin
    await this.ensureOwnerOrAdmin(adderId, smartGroup.companyId);

    // Verify user exists and is in the company
    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
    });

    if (!user || user.companyId !== smartGroup.companyId) {
      throw new NotFoundException('User not found in this company');
    }

    if (user.joinRequestStatus !== JoinRequestStatus.APPROVED) {
      throw new BadRequestException('User must be approved to join smart groups');
    }

    // Check if already a member
    const existing = await this.prisma.smartGroupMember.findUnique({
      where: {
        smartGroupId_userId: {
          smartGroupId,
          userId: dto.userId,
        },
      },
    });

    if (existing) {
      throw new ConflictException('User is already a member of this smart group');
    }

    return this.prisma.smartGroupMember.create({
      data: {
        smartGroupId,
        userId: dto.userId,
      },
    });
  }

  async removeMember(smartGroupId: string, userId: string, removerId: string) {
    const smartGroup = await this.prisma.smartGroup.findUnique({
      where: { id: smartGroupId },
    });

    if (!smartGroup) {
      throw new NotFoundException('Smart group not found');
    }

    if (!smartGroup.isManual) {
      throw new BadRequestException('Cannot manually remove members from automatic smart groups');
    }

    // Verify remover is Owner or Admin
    await this.ensureOwnerOrAdmin(removerId, smartGroup.companyId);

    await this.prisma.smartGroupMember.delete({
      where: {
        smartGroupId_userId: {
          smartGroupId,
          userId,
        },
      },
    });

    return { message: 'Member removed from smart group' };
  }

  // =====================================================
  // AUTO-ASSIGNMENT LOGIC
  // =====================================================

  private async autoAssignMembers(smartGroupId: string) {
    const smartGroup = await this.prisma.smartGroup.findUnique({
      where: { id: smartGroupId },
    });

    if (!smartGroup || smartGroup.isManual || !smartGroup.criteria) {
      return;
    }

    const criteria = smartGroup.criteria as any;

    // Build query based on criteria
    const where: any = {
      companyId: smartGroup.companyId,
      joinRequestStatus: JoinRequestStatus.APPROVED,
    };

    if (criteria.directManagerId) {
      where.directManagerId = criteria.directManagerId;
    }

    if (criteria.roleId) {
      where.roleId = criteria.roleId;
    }

    if (criteria.orgUnitId) {
      where.orgUnitId = criteria.orgUnitId;
    }

    if (criteria.userType) {
      where.userType = criteria.userType;
    }

    // Custom fields matching (JSON)
    if (criteria.customField) {
      // This requires more complex filtering - for now we'll skip
      // In production, you'd use Prisma's JSON filtering or post-query filtering
    }

    const matchingUsers = await this.prisma.user.findMany({
      where,
      select: { id: true },
    });

    // Add all matching users
    const memberData = matchingUsers.map(user => ({
      smartGroupId: smartGroup.id,
      userId: user.id,
    }));

    await this.prisma.smartGroupMember.createMany({
      data: memberData,
      skipDuplicates: true,
    });
  }

  private async refreshAutoAssignments(smartGroupId: string) {
    // Remove all existing members
    await this.prisma.smartGroupMember.deleteMany({
      where: { smartGroupId },
    });

    // Re-add based on criteria
    await this.autoAssignMembers(smartGroupId);
  }

  // =====================================================
  // HELPERS
  // =====================================================

  private async ensureOwnerOrAdmin(userId: string, companyId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (
      !user ||
      user.companyId !== companyId ||
      (user.userType !== UserType.OWNER && user.userType !== UserType.ADMIN)
    ) {
      throw new ForbiddenException('Only company owners or admins can perform this action');
    }

    return user;
  }
}

import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBranchDto } from './dto/create-branch.dto';
import { UpdateBranchDto } from './dto/update-branch.dto';
import { UserType } from '@prisma/client';

@Injectable()
export class BranchesService {
  constructor(private prisma: PrismaService) {}

  async create(companyId: string, dto: CreateBranchDto, creatorId: string) {
    // Verify creator is Owner or Admin
    await this.ensureOwnerOrAdmin(creatorId, companyId);

    // Check for duplicate name
    const existing = await this.prisma.branch.findUnique({
      where: {
        companyId_name: {
          companyId,
          name: dto.name,
        },
      },
    });

    if (existing) {
      throw new ConflictException('Branch with this name already exists');
    }

    // If this is marked as headquarters, unset any existing headquarters
    if (dto.isHeadquarters) {
      await this.prisma.branch.updateMany({
        where: {
          companyId,
          isHeadquarters: true,
        },
        data: {
          isHeadquarters: false,
        },
      });
    }

    return this.prisma.branch.create({
      data: {
        companyId,
        ...dto,
      },
    });
  }

  async findAll(companyId: string) {
    return this.prisma.branch.findMany({
      where: { companyId },
      include: {
        _count: {
          select: {
            users: true,
            materials: true,
          },
        },
      },
      orderBy: [
        { isHeadquarters: 'desc' },
        { name: 'asc' },
      ],
    });
  }

  async findOne(id: string) {
    const branch = await this.prisma.branch.findUnique({
      where: { id },
      include: {
        users: {
          select: {
            id: true,
            name: true,
            email: true,
            userType: true,
          },
        },
        _count: {
          select: {
            materials: true,
          },
        },
      },
    });

    if (!branch) {
      throw new NotFoundException('Branch not found');
    }

    return branch;
  }

  async update(id: string, dto: UpdateBranchDto, updaterId: string) {
    const branch = await this.prisma.branch.findUnique({
      where: { id },
    });

    if (!branch) {
      throw new NotFoundException('Branch not found');
    }

    await this.ensureOwnerOrAdmin(updaterId, branch.companyId);

    // If this is being set as headquarters, unset any existing headquarters
    if (dto.isHeadquarters) {
      await this.prisma.branch.updateMany({
        where: {
          companyId: branch.companyId,
          isHeadquarters: true,
          id: { not: id },
        },
        data: {
          isHeadquarters: false,
        },
      });
    }

    return this.prisma.branch.update({
      where: { id },
      data: dto,
    });
  }

  async delete(id: string, deleterId: string) {
    const branch = await this.prisma.branch.findUnique({
      where: { id },
    });

    if (!branch) {
      throw new NotFoundException('Branch not found');
    }

    await this.ensureOwnerOrAdmin(deleterId, branch.companyId);

    // Check if branch has users
    const userCount = await this.prisma.user.count({
      where: { branchId: id },
    });

    if (userCount > 0) {
      throw new ConflictException('Cannot delete branch that has assigned users');
    }

    await this.prisma.branch.delete({
      where: { id },
    });

    return { message: 'Branch deleted successfully' };
  }

  async assignUserToBranch(userId: string, branchId: string, assignerId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    const branch = await this.prisma.branch.findUnique({
      where: { id: branchId },
    });

    if (!user || !branch) {
      throw new NotFoundException('User or branch not found');
    }

    if (user.companyId !== branch.companyId) {
      throw new ConflictException('User and branch must belong to the same company');
    }

    await this.ensureOwnerOrAdmin(assignerId, branch.companyId);

    await this.prisma.user.update({
      where: { id: userId },
      data: { branchId },
    });

    return { message: 'User assigned to branch successfully' };
  }

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

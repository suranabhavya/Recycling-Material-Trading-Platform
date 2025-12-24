import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateRoleDto } from './dto/create-role.dto';
import { UserType } from '@prisma/client';

@Injectable()
export class RolesService {
  constructor(private prisma: PrismaService) {}

  async create(companyId: string, dto: CreateRoleDto, creatorId: string) {
    // Verify creator is Owner or Admin
    await this.ensureOwnerOrAdmin(creatorId, companyId);

    // Check for duplicate name
    const existing = await this.prisma.role.findUnique({
      where: {
        companyId_name: {
          companyId,
          name: dto.name,
        },
      },
    });

    if (existing) {
      throw new ConflictException('Role with this name already exists');
    }

    return this.prisma.role.create({
      data: {
        companyId,
        name: dto.name,
        description: dto.description,
        color: dto.color,
      },
    });
  }

  async findAll(companyId: string) {
    return this.prisma.role.findMany({
      where: { companyId },
      include: {
        _count: {
          select: {
            users: true,
          },
        },
      },
      orderBy: {
        name: 'asc',
      },
    });
  }

  async findOne(id: string) {
    const role = await this.prisma.role.findUnique({
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
      },
    });

    if (!role) {
      throw new NotFoundException('Role not found');
    }

    return role;
  }

  async update(id: string, dto: CreateRoleDto, updaterId: string) {
    const role = await this.prisma.role.findUnique({
      where: { id },
    });

    if (!role) {
      throw new NotFoundException('Role not found');
    }

    await this.ensureOwnerOrAdmin(updaterId, role.companyId);

    return this.prisma.role.update({
      where: { id },
      data: dto,
    });
  }

  async delete(id: string, deleterId: string) {
    const role = await this.prisma.role.findUnique({
      where: { id },
    });

    if (!role) {
      throw new NotFoundException('Role not found');
    }

    await this.ensureOwnerOrAdmin(deleterId, role.companyId);

    // Check if role is assigned to users
    const userCount = await this.prisma.user.count({
      where: { roleId: id },
    });

    if (userCount > 0) {
      throw new ConflictException('Cannot delete role that is assigned to users');
    }

    await this.prisma.role.delete({
      where: { id },
    });

    return { message: 'Role deleted successfully' };
  }

  async assignRoleToUser(userId: string, roleId: string, assignerId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    const role = await this.prisma.role.findUnique({
      where: { id: roleId },
    });

    if (!user || !role) {
      throw new NotFoundException('User or role not found');
    }

    if (user.companyId !== role.companyId) {
      throw new ConflictException('User and role must belong to the same company');
    }

    await this.ensureOwnerOrAdmin(assignerId, role.companyId);

    await this.prisma.user.update({
      where: { id: userId },
      data: { roleId },
    });

    return { message: 'Role assigned to user successfully' };
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

import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getCompanyUsers(companyId: string) {
    const users = await this.prisma.user.findMany({
      where: { companyId },
      include: {
        branch: {
          include: {
            _count: {
              select: {
                users: true,
                materials: true,
              },
            },
          },
        },
        role: {
          include: {
            _count: {
              select: {
                users: true,
              },
            },
          },
        },
        directManager: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    // Manually count direct reports for each user
    const usersWithCounts = await Promise.all(
      users.map(async (user) => {
        const directReportsCount = await this.prisma.user.count({
          where: { directManagerId: user.id },
        });
        return {
          ...user,
          _count: {
            directReports: directReportsCount,
          },
        };
      }),
    );

    return usersWithCounts;
  }

  async getUsersByBranch(branchId: string) {
    const users = await this.prisma.user.findMany({
      where: { branchId },
      include: {
        branch: true,
        role: true,
        directManager: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    // Manually count direct reports for each user
    const usersWithCounts = await Promise.all(
      users.map(async (user) => {
        const directReportsCount = await this.prisma.user.count({
          where: { directManagerId: user.id },
        });
        return {
          ...user,
          _count: {
            directReports: directReportsCount,
          },
        };
      }),
    );

    return usersWithCounts;
  }

  async getUserById(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        branch: true,
        role: true,
        directManager: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Manually count direct reports
    const directReportsCount = await this.prisma.user.count({
      where: { directManagerId: userId },
    });

    return {
      ...user,
      _count: {
        directReports: directReportsCount,
      },
    };
  }

  async updateUser(userId: string, data: any) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data,
      include: {
        branch: true,
        role: true,
        directManager: true,
      },
    });

    // Manually count direct reports
    const directReportsCount = await this.prisma.user.count({
      where: { directManagerId: userId },
    });

    return {
      ...user,
      _count: {
        directReports: directReportsCount,
      },
    };
  }

  async assignManager(userId: string, managerId: string | null) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { directManagerId: managerId },
      include: {
        directManager: true,
      },
    });
  }

  async assignBranch(userId: string, branchId: string) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { branchId },
      include: {
        branch: true,
      },
    });
  }

  async assignRole(userId: string, roleId: string | null) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { roleId },
      include: {
        role: true,
      },
    });
  }

  async deleteUser(userId: string) {
    return this.prisma.user.delete({
      where: { id: userId },
    });
  }
}

import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCompanyDto } from './dto/create-company.dto';
import { JoinCompanyDto } from './dto/join-company.dto';
import { AssignManagerDto } from './dto/assign-manager.dto';
import { UpdateUserTypeDto } from './dto/update-user-type.dto';
import { UserType, JoinRequestStatus } from '@prisma/client';

@Injectable()
export class CompanyService {
  constructor(private prisma: PrismaService) {}

  // =====================================================
  // COMPANY CREATION & MANAGEMENT
  // =====================================================

  async create(createCompanyDto: CreateCompanyDto, userId: string) {
    // Check if company with email already exists
    const existing = await this.prisma.company.findUnique({
      where: { email: createCompanyDto.email },
    });

    if (existing) {
      throw new ConflictException('Company with this email already exists');
    }

    // Create company
    const company = await this.prisma.company.create({
      data: createCompanyDto,
    });

    // Make the creator the OWNER
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        companyId: company.id,
        userType: UserType.OWNER,
        joinRequestStatus: JoinRequestStatus.APPROVED,
      },
    });

    return company;
  }

  async findAll() {
    return this.prisma.company.findMany({
      select: {
        id: true,
        name: true,
        type: true,
        email: true,
        phone: true,
        address: true,
        createdAt: true,
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
    const company = await this.prisma.company.findUnique({
      where: { id },
      include: {
        users: {
          where: {
            joinRequestStatus: JoinRequestStatus.APPROVED,
          },
          select: {
            id: true,
            name: true,
            email: true,
            phone: true,
            userType: true,
            role: {
              select: {
                id: true,
                name: true,
                color: true,
              },
            },
            directManager: {
              select: {
                id: true,
                name: true,
              },
            },
            _count: {
              select: {
                directReports: true,
              },
            },
          },
          orderBy: {
            name: 'asc',
          },
        },
        roles: true,
        _count: {
          select: {
            materials: true,
            smartGroups: true,
          },
        },
      },
    });

    if (!company) {
      throw new NotFoundException('Company not found');
    }

    return company;
  }

  // =====================================================
  // JOIN REQUESTS
  // =====================================================

  async joinCompany(joinCompanyDto: JoinCompanyDto, userId: string) {
    const company = await this.prisma.company.findUnique({
      where: { id: joinCompanyDto.companyId },
    });

    if (!company) {
      throw new NotFoundException('Company not found');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (user?.companyId) {
      throw new BadRequestException('You are already part of a company');
    }

    // Create join request (status will be PENDING by default)
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        companyId: company.id,
        userType: UserType.USER, // Default to USER
        joinRequestStatus: JoinRequestStatus.PENDING,
      },
    });

    return {
      message: 'Request sent to company owner/admin for approval',
      company,
    };
  }

  async getPendingJoinRequests(companyId: string, requesterId: string) {
    // Check if requester is Owner or Admin
    await this.ensureOwnerOrAdmin(requesterId, companyId);

    return this.prisma.user.findMany({
      where: {
        companyId,
        joinRequestStatus: JoinRequestStatus.PENDING,
      },
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        createdAt: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async approveJoinRequest(userId: string, approverId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { company: true },
    });

    if (!user || !user.companyId) {
      throw new NotFoundException('User or company not found');
    }

    // Ensure approver is Owner or Admin
    await this.ensureOwnerOrAdmin(approverId, user.companyId);

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        joinRequestStatus: JoinRequestStatus.APPROVED,
      },
    });

    return { message: 'User approved successfully' };
  }

  async rejectJoinRequest(userId: string, rejecterId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { company: true },
    });

    if (!user || !user.companyId) {
      throw new NotFoundException('User or company not found');
    }

    // Ensure rejecter is Owner or Admin
    await this.ensureOwnerOrAdmin(rejecterId, user.companyId);

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        joinRequestStatus: JoinRequestStatus.REJECTED,
        companyId: null,
        userType: UserType.USER,
      },
    });

    return { message: 'User join request rejected' };
  }

  // =====================================================
  // USER MANAGEMENT
  // =====================================================

  async getCompanyMembers(companyId: string) {
    return this.prisma.user.findMany({
      where: {
        companyId,
        joinRequestStatus: JoinRequestStatus.APPROVED,
      },
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        userType: true,
        role: {
          select: {
            id: true,
            name: true,
            color: true,
          },
        },
        directManager: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        orgUnit: {
          select: {
            id: true,
            name: true,
          },
        },
        customFields: true,
        _count: {
          select: {
            directReports: true,
          },
        },
        createdAt: true,
      },
      orderBy: [
        {
          userType: 'asc', // OWNER, ADMIN, USER
        },
        {
          name: 'asc',
        },
      ],
    });
  }

  async updateUserType(dto: UpdateUserTypeDto, requesterId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
    });

    if (!user || !user.companyId) {
      throw new NotFoundException('User not found');
    }

    // Only OWNER can change user types
    await this.ensureOwner(requesterId, user.companyId);

    // Cannot demote yourself if you're the only owner
    if (user.id === requesterId && dto.userType !== UserType.OWNER) {
      const ownerCount = await this.prisma.user.count({
        where: {
          companyId: user.companyId,
          userType: UserType.OWNER,
          joinRequestStatus: JoinRequestStatus.APPROVED,
        },
      });

      if (ownerCount === 1) {
        throw new BadRequestException('Cannot demote the only owner');
      }
    }

    await this.prisma.user.update({
      where: { id: dto.userId },
      data: { userType: dto.userType },
    });

    return { message: `User type updated to ${dto.userType}` };
  }

  async assignDirectManager(dto: AssignManagerDto, requesterId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
    });

    const manager = await this.prisma.user.findUnique({
      where: { id: dto.managerId },
    });

    if (!user || !manager) {
      throw new NotFoundException('User or manager not found');
    }

    if (!user.companyId || user.companyId !== manager.companyId) {
      throw new BadRequestException('Users must be from the same company');
    }

    // Only Owner or Admin can assign managers
    await this.ensureOwnerOrAdmin(requesterId, user.companyId);

    // Prevent circular management
    if (dto.userId === dto.managerId) {
      throw new BadRequestException('User cannot be their own manager');
    }

    await this.prisma.user.update({
      where: { id: dto.userId },
      data: { directManagerId: dto.managerId },
    });

    return { message: 'Direct manager assigned successfully' };
  }

  async removeFromCompany(userId: string, removerId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || !user.companyId) {
      throw new NotFoundException('User not found');
    }

    // Only Owner or Admin can remove users
    await this.ensureOwnerOrAdmin(removerId, user.companyId);

    // Cannot remove an OWNER
    if (user.userType === UserType.OWNER) {
      throw new BadRequestException('Cannot remove an owner from the company');
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        companyId: null,
        userType: UserType.USER,
        joinRequestStatus: null,
        directManagerId: null,
        roleId: null,
        orgUnitId: null,
      },
    });

    return { message: 'User removed from company' };
  }

  // =====================================================
  // ORG CHART
  // =====================================================

  async getOrgChart(companyId: string) {
    // Get all approved users
    const users = await this.prisma.user.findMany({
      where: {
        companyId,
        joinRequestStatus: JoinRequestStatus.APPROVED,
      },
      select: {
        id: true,
        name: true,
        email: true,
        userType: true,
        directManagerId: true,
        role: {
          select: {
            id: true,
            name: true,
            color: true,
          },
        },
        orgUnit: {
          select: {
            id: true,
            name: true,
          },
        },
        _count: {
          select: {
            directReports: true,
          },
        },
      },
      orderBy: {
        name: 'asc',
      },
    });

    // Build tree structure
    const userMap = new Map(users.map(u => [u.id, { ...u, children: [] as any[] }]));
    const roots: any[] = [];

    users.forEach(user => {
      const node = userMap.get(user.id);
      if (node && user.directManagerId) {
        const parent = userMap.get(user.directManagerId);
        if (parent && parent.children) {
          parent.children.push(node);
        } else {
          roots.push(node);
        }
      } else if (node) {
        roots.push(node);
      }
    });

    return roots;
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================

  private async ensureOwner(userId: string, companyId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || user.companyId !== companyId || user.userType !== UserType.OWNER) {
      throw new ForbiddenException('Only company owners can perform this action');
    }

    return user;
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

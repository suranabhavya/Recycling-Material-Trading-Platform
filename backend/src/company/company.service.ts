import { Injectable, ConflictException, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCompanyDto } from './dto/create-company.dto';
import { JoinCompanyDto } from './dto/join-company.dto';
import { ApprovalStatus } from '@prisma/client';

@Injectable()
export class CompanyService {
  constructor(private prisma: PrismaService) {}

  async create(createCompanyDto: CreateCompanyDto, userId: string) {
    const existingCompany = await this.prisma.company.findUnique({
      where: { email: createCompanyDto.email },
    });

    if (existingCompany) {
      throw new ConflictException('Company with this email already exists');
    }

    const { roleTemplates, orgUnits, ...companyData } = createCompanyDto;

    const company = await this.prisma.company.create({
      data: {
        ...companyData,
        roleTemplates: {
          create: roleTemplates,
        },
        orgUnits: orgUnits ? {
          create: orgUnits,
        } : undefined,
      },
      include: {
        roleTemplates: true,
      },
    });

    const adminRole = company.roleTemplates.find(r => r.level === 1);

    if (!adminRole) {
      throw new BadRequestException('Level 1 (Admin) role template is required');
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        companyId: company.id,
        roleTemplateId: adminRole.id,
        companyApprovalStatus: ApprovalStatus.APPROVED,
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
        hierarchyMode: true,
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
        roleTemplates: {
          orderBy: { level: 'asc' },
        },
        users: {
          select: {
            id: true,
            name: true,
            email: true,
            roleTemplate: {
              select: {
                id: true,
                name: true,
                level: true,
              },
            },
            companyApprovalStatus: true,
          },
        },
      },
    });

    if (!company) {
      throw new NotFoundException('Company not found');
    }

    return company;
  }

  async joinCompany(joinCompanyDto: JoinCompanyDto, userId: string) {
    const company = await this.prisma.company.findUnique({
      where: { id: joinCompanyDto.companyId },
      include: {
        roleTemplates: {
          orderBy: { level: 'desc' },
          take: 1,
        },
      },
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

    const lowestRole = company.roleTemplates[0];

    if (!lowestRole) {
      throw new BadRequestException('Company has no role templates defined');
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        companyId: company.id,
        roleTemplateId: lowestRole.id,
        companyApprovalStatus: ApprovalStatus.PENDING,
      },
    });

    return {
      message: 'Request sent to company admin for approval',
      company,
    };
  }

  async getPendingApprovals(companyId: string) {
    return this.prisma.user.findMany({
      where: {
        companyId,
        companyApprovalStatus: ApprovalStatus.PENDING,
      },
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
        createdAt: true,
      },
    });
  }

  async approveUser(userId: string, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
      include: { roleTemplate: true },
    });

    if (!admin?.roleTemplate || admin.roleTemplate.level !== 1) {
      throw new BadRequestException('Only admins can approve users');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (user?.companyId !== admin.companyId) {
      throw new BadRequestException('User not from your company');
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        companyApprovalStatus: ApprovalStatus.APPROVED,
      },
    });

    return { message: 'User approved successfully' };
  }

  async rejectUser(userId: string, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
      include: { roleTemplate: true },
    });

    if (!admin?.roleTemplate || admin.roleTemplate.level !== 1) {
      throw new BadRequestException('Only admins can reject users');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (user?.companyId !== admin.companyId) {
      throw new BadRequestException('User not from your company');
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        companyApprovalStatus: ApprovalStatus.REJECTED,
      },
    });

    return { message: 'User rejected' };
  }

  async getCompanyMembers(companyId: string) {
    return this.prisma.user.findMany({
      where: {
        companyId,
        companyApprovalStatus: ApprovalStatus.APPROVED,
      },
      select: {
        id: true,
        name: true,
        email: true,
        roleTemplate: {
          select: {
            id: true,
            name: true,
            level: true,
          },
        },
        manager: {
          select: {
            id: true,
            name: true,
          },
        },
        orgUnit: {
          select: {
            id: true,
            name: true,
          },
        },
        createdAt: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async updateUserRole(userId: string, roleTemplateId: string, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
      include: { roleTemplate: true },
    });

    if (!admin?.roleTemplate || admin.roleTemplate.level !== 1) {
      throw new BadRequestException('Only admins can update user roles');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { roleTemplate: true },
    });

    if (!user || user.companyId !== admin.companyId) {
      throw new BadRequestException('User not from your company');
    }

    if (user.roleTemplate?.level === 1 && userId !== adminId) {
      throw new BadRequestException('Cannot change the role of another admin');
    }

    const newRole = await this.prisma.roleTemplate.findUnique({
      where: { id: roleTemplateId },
    });

    if (!newRole || newRole.companyId !== admin.companyId) {
      throw new BadRequestException('Invalid role template');
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: { roleTemplateId },
    });

    return { message: `User role updated to ${newRole.name}` };
  }

  async assignManager(userId: string, managerId: string, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
      include: { roleTemplate: true },
    });

    if (!admin?.roleTemplate || admin.roleTemplate.level !== 1) {
      throw new ForbiddenException('Only admins can assign managers');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    const manager = await this.prisma.user.findUnique({
      where: { id: managerId },
      include: { roleTemplate: true },
    });

    if (!user || !manager) {
      throw new NotFoundException('User or manager not found');
    }

    if (user.companyId !== admin.companyId || manager.companyId !== admin.companyId) {
      throw new BadRequestException('Users must be from your company');
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: { managerId },
    });

    return { message: 'Manager assigned successfully' };
  }

  async assignOrgUnit(userId: string, orgUnitId: string, adminId: string, isOrgUnitHead: boolean = false) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
      include: { roleTemplate: true },
    });

    if (!admin?.roleTemplate || admin.roleTemplate.level !== 1) {
      throw new ForbiddenException('Only admins can assign organizational units');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    const orgUnit = await this.prisma.organizationalUnit.findUnique({
      where: { id: orgUnitId },
    });

    if (!user || !orgUnit) {
      throw new NotFoundException('User or organizational unit not found');
    }

    if (user.companyId !== admin.companyId || orgUnit.companyId !== admin.companyId) {
      throw new BadRequestException('User and org unit must be from your company');
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        orgUnitId,
        isOrgUnitHead,
      },
    });

    return { message: 'Organizational unit assigned successfully' };
  }

  async kickMember(userId: string, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
      include: { roleTemplate: true },
    });

    if (!admin?.roleTemplate || admin.roleTemplate.level !== 1) {
      throw new BadRequestException('Only admins can kick members');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { roleTemplate: true },
    });

    if (!user || user.companyId !== admin.companyId) {
      throw new BadRequestException('User not from your company');
    }

    if (user.roleTemplate?.level === 1) {
      throw new BadRequestException('Cannot kick another admin');
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        companyApprovalStatus: ApprovalStatus.REJECTED,
      },
    });

    return { message: 'User kicked from company' };
  }

  async getSubordinates(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        company: true,
        roleTemplate: true,
      },
    });

    if (!user || !user.roleTemplate) {
      throw new NotFoundException('User not found');
    }

    return this.prisma.user.findMany({
      where: {
        companyId: user.companyId,
        managerId: userId,
        companyApprovalStatus: ApprovalStatus.APPROVED,
      },
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
        createdAt: true,
      },
      orderBy: {
        name: 'asc',
      },
    });
  }

  async getCompanyHierarchy(companyId: string) {
    const users = await this.prisma.user.findMany({
      where: {
        companyId,
        companyApprovalStatus: ApprovalStatus.APPROVED,
      },
      select: {
        id: true,
        name: true,
        email: true,
        managerId: true,
        createdAt: true,
        roleTemplate: {
          select: {
            id: true,
            name: true,
            level: true,
          },
        },
        orgUnit: {
          select: {
            id: true,
            name: true,
          },
        },
        isOrgUnitHead: true,
        subordinates: {
          select: {
            id: true,
            name: true,
            email: true,
            roleTemplate: {
              select: {
                name: true,
              },
            },
            createdAt: true,
          },
        },
      },
      orderBy: {
        roleTemplate: {
          level: 'asc',
        },
      },
    });

    // Transform the data into the expected structure
    const admins = users
      .filter((user) => user.roleTemplate?.level === 1)
      .map((user) => ({
        id: user.id,
        name: user.name,
        email: user.email,
      }));

    // Leads are users with level 2 or users who have subordinates (managers)
    const leads = users
      .filter((user) => {
        const level = user.roleTemplate?.level;
        // Level 2 or users who have subordinates (are managers)
        return (level === 2 || (level && level > 1 && user.subordinates.length > 0));
      })
      .map((user) => ({
        id: user.id,
        name: user.name,
        email: user.email,
        _count: {
          teamMembers: user.subordinates.length,
        },
        teamMembers: user.subordinates.map((sub) => ({
          id: sub.id,
          name: sub.name,
          email: sub.email,
          role: sub.roleTemplate?.name,
          createdAt: sub.createdAt,
        })),
      }));

    // Get all user IDs that are admins or leads
    const adminAndLeadIds = new Set([
      ...admins.map((a) => a.id),
      ...leads.map((l) => l.id),
    ]);

    // Get all user IDs that are assigned to leads (subordinates)
    const assignedMemberIds = new Set(
      leads.flatMap((lead) => lead.teamMembers.map((m) => m.id)),
    );

    // Unassigned members are users who are not admins, not leads, and not assigned to any lead
    const unassignedMembers = users
      .filter(
        (user) =>
          !adminAndLeadIds.has(user.id) && !assignedMemberIds.has(user.id),
      )
      .map((user) => ({
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.roleTemplate?.name,
        createdAt: user.createdAt,
      }));

    return {
      admins,
      leads,
      unassignedMembers,
    };
  }
}

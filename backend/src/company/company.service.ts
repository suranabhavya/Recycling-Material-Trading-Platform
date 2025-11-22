import { Injectable, ConflictException, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCompanyDto } from './dto/create-company.dto';
import { JoinCompanyDto } from './dto/join-company.dto';
import { ApprovalStatus, UserRole } from '@prisma/client';

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

    const company = await this.prisma.company.create({
      data: createCompanyDto,
    });

    // Assign user as ADMIN of the company they created
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        companyId: company.id,
        role: UserRole.ADMIN,
        companyApprovalStatus: ApprovalStatus.APPROVED, // Auto-approve for company creator
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
          select: {
            id: true,
            name: true,
            email: true,
            role: true,
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

    // Join company with PENDING status (needs admin approval)
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        companyId: company.id,
        role: UserRole.MEMBER,
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
        createdAt: true,
      },
    });
  }

  async approveUser(userId: string, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (admin?.role !== UserRole.ADMIN) {
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
    });

    if (admin?.role !== UserRole.ADMIN) {
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
        role: true,
        createdAt: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async updateUserRole(userId: string, newRole: UserRole, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (admin?.role !== UserRole.ADMIN) {
      throw new BadRequestException('Only admins can update user roles');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || user.companyId !== admin.companyId) {
      throw new BadRequestException('User not from your company');
    }

    if (user.role === UserRole.ADMIN) {
      throw new BadRequestException('Cannot change the role of another admin');
    }

    // Validate role transitions
    if (newRole === UserRole.ADMIN || newRole === UserRole.LEAD || newRole === UserRole.MEMBER) {
      await this.prisma.user.update({
        where: { id: userId },
        data: { role: newRole },
      });
    } else {
      throw new BadRequestException('Invalid role');
    }

    return { message: `User role updated to ${newRole}` };
  }

  async kickMember(userId: string, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (admin?.role !== UserRole.ADMIN) {
      throw new BadRequestException('Only admins can kick members');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || user.companyId !== admin.companyId) {
      throw new BadRequestException('User not from your company');
    }

    if (user.role === UserRole.ADMIN) {
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

  // Assign a lead to a member
  async assignLead(memberId: string, leadId: string, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (admin?.role !== UserRole.ADMIN) {
      throw new ForbiddenException('Only admins can assign leads');
    }

    const member = await this.prisma.user.findUnique({
      where: { id: memberId },
    });

    const lead = await this.prisma.user.findUnique({
      where: { id: leadId },
    });

    if (!member || !lead) {
      throw new NotFoundException('Member or lead not found');
    }

    if (member.companyId !== admin.companyId || lead.companyId !== admin.companyId) {
      throw new BadRequestException('Member and lead must be from your company');
    }

    if (member.role !== UserRole.MEMBER) {
      throw new BadRequestException('Can only assign leads to members');
    }

    if (lead.role !== UserRole.LEAD) {
      throw new BadRequestException('Selected user is not a lead');
    }

    await this.prisma.user.update({
      where: { id: memberId },
      data: { leadId },
    });

    return { message: 'Lead assigned successfully' };
  }

  // Get team members for a lead
  async getTeamMembers(leadId: string) {
    const lead = await this.prisma.user.findUnique({
      where: { id: leadId },
    });

    if (lead?.role !== UserRole.LEAD) {
      throw new ForbiddenException('Only leads can view their team');
    }

    return this.prisma.user.findMany({
      where: {
        leadId: leadId,
        companyApprovalStatus: ApprovalStatus.APPROVED,
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        createdAt: true,
      },
      orderBy: {
        name: 'asc',
      },
    });
  }

  // Get all leads in company (for admin)
  async getCompanyLeads(companyId: string) {
    return this.prisma.user.findMany({
      where: {
        companyId,
        role: UserRole.LEAD,
        companyApprovalStatus: ApprovalStatus.APPROVED,
      },
      select: {
        id: true,
        name: true,
        email: true,
        _count: {
          select: {
            teamMembers: true,
          },
        },
      },
      orderBy: {
        name: 'asc',
      },
    });
  }

  // Get company hierarchy structure
  async getCompanyHierarchy(companyId: string) {
    const admins = await this.prisma.user.findMany({
      where: {
        companyId,
        role: UserRole.ADMIN,
        companyApprovalStatus: ApprovalStatus.APPROVED,
      },
      select: {
        id: true,
        name: true,
        email: true,
      },
    });

    const leads = await this.prisma.user.findMany({
      where: {
        companyId,
        role: UserRole.LEAD,
        companyApprovalStatus: ApprovalStatus.APPROVED,
      },
      select: {
        id: true,
        name: true,
        email: true,
        teamMembers: {
          where: {
            companyApprovalStatus: ApprovalStatus.APPROVED,
          },
          select: {
            id: true,
            name: true,
            email: true,
            role: true,
          },
        },
      },
    });

    const unassignedMembers = await this.prisma.user.findMany({
      where: {
        companyId,
        role: UserRole.MEMBER,
        leadId: null,
        companyApprovalStatus: ApprovalStatus.APPROVED,
      },
      select: {
        id: true,
        name: true,
        email: true,
      },
    });

    // Add member count to leads
    const leadsWithCount = leads.map(lead => ({
      ...lead,
      _count: {
        teamMembers: lead.teamMembers.length,
      },
    }));

    return {
      admins,
      leads: leadsWithCount,
      unassignedMembers,
    };
  }

  // Assign member to lead
  async assignMemberToLead(memberId: string, leadId: string, adminId: string) {
    // Verify admin has permission
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (!admin || admin.role !== UserRole.ADMIN) {
      throw new ForbiddenException('Only admins can assign members to leads');
    }

    // Verify member exists and is a MEMBER
    const member = await this.prisma.user.findUnique({
      where: { id: memberId },
    });

    if (!member) {
      throw new NotFoundException('Member not found');
    }

    if (member.role !== UserRole.MEMBER) {
      throw new BadRequestException('Only members with MEMBER role can be assigned to leads');
    }

    // Verify lead exists and is a LEAD
    const lead = await this.prisma.user.findUnique({
      where: { id: leadId },
    });

    if (!lead) {
      throw new NotFoundException('Lead not found');
    }

    if (lead.role !== UserRole.LEAD) {
      throw new BadRequestException('Target user is not a lead');
    }

    // Verify they're in the same company
    if (member.companyId !== lead.companyId || member.companyId !== admin.companyId) {
      throw new BadRequestException('Member and lead must be in the same company');
    }

    // Assign member to lead
    await this.prisma.user.update({
      where: { id: memberId },
      data: { leadId },
    });

    return {
      message: 'Member assigned to lead successfully',
      member: {
        id: member.id,
        name: member.name,
        leadId,
      },
    };
  }

  // Unassign member from lead
  async unassignMemberFromLead(memberId: string, adminId: string) {
    // Verify admin has permission
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (!admin || admin.role !== UserRole.ADMIN) {
      throw new ForbiddenException('Only admins can unassign members from leads');
    }

    // Verify member exists
    const member = await this.prisma.user.findUnique({
      where: { id: memberId },
    });

    if (!member) {
      throw new NotFoundException('Member not found');
    }

    // Verify they're in the same company
    if (member.companyId !== admin.companyId) {
      throw new BadRequestException('Member must be in the same company');
    }

    // Unassign member from lead
    await this.prisma.user.update({
      where: { id: memberId },
      data: { leadId: null },
    });

    return {
      message: 'Member unassigned from lead successfully',
      member: {
        id: member.id,
        name: member.name,
        leadId: null,
      },
    };
  }
}


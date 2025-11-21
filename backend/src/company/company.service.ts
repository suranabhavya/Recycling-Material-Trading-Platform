import { Injectable, ConflictException, NotFoundException, BadRequestException } from '@nestjs/common';
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
        companyId: null,
        role: null,
        companyApprovalStatus: null,
      },
    });

    return { message: 'User rejected and removed from company' };
  }
}


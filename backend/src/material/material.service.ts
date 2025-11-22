import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMaterialDto } from './dto/create-material.dto';
import { UpdateMaterialDto } from './dto/update-material.dto';

@Injectable()
export class MaterialService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, createMaterialDto: CreateMaterialDto) {
    // Get user's company
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { company: true },
    });

    if (!user || !user.companyId) {
      throw new ForbiddenException('You must be part of a company to create materials');
    }

    if (user.companyApprovalStatus !== 'APPROVED') {
      throw new ForbiddenException('Your company membership must be approved first');
    }

    // If user is a LEAD, auto-approve their material
    const status = user.role === 'LEAD' ? 'APPROVED_BY_LEAD' : 'PENDING_LEAD_APPROVAL';
    const leadId = user.role === 'LEAD' ? userId : null;
    const leadApprovedAt = user.role === 'LEAD' ? new Date() : null;

    return this.prisma.material.create({
      data: {
        ...createMaterialDto,
        userId,
        companyId: user.companyId,
        status,
        leadId,
        leadApprovedAt,
      },
      include: {
        user: {
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
        user: {
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
  }

  async findOne(id: string, userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    const material = await this.prisma.material.findUnique({
      where: { id },
      include: {
        user: {
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

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    // Check if user is from the same company
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

    // Only the creator can update
    if (material.userId !== userId) {
      throw new ForbiddenException('You can only update your own materials');
    }

    return this.prisma.material.update({
      where: { id },
      data: updateMaterialDto,
      include: {
        user: {
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
    });

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    // Only the creator can delete
    if (material.userId !== userId) {
      throw new ForbiddenException('You can only delete your own materials');
    }

    await this.prisma.material.delete({
      where: { id },
    });

    return { message: 'Material deleted successfully' };
  }

  // TODO: This will be replaced with batch approval workflow
  // Admin can approve/reject materials (deprecated - will use batch approval)
  async updateStatus(id: string, userId: string, status: 'APPROVED_BY_ADMIN' | 'REJECTED_BY_ADMIN') {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (user?.role !== 'ADMIN') {
      throw new ForbiddenException('Only admins can update material status');
    }

    const material = await this.prisma.material.findUnique({
      where: { id },
    });

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    if (material.companyId !== user.companyId) {
      throw new ForbiddenException('You can only manage materials from your company');
    }

    return this.prisma.material.update({
      where: { id },
      data: { status },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  // Get materials pending approval for a lead
  async getPendingLeadApproval(leadId: string) {
    const lead = await this.prisma.user.findUnique({
      where: { id: leadId },
    });

    if (lead?.role !== 'LEAD') {
      throw new ForbiddenException('Only leads can view pending materials');
    }

    // Get all members under this lead
    const teamMembers = await this.prisma.user.findMany({
      where: { leadId: leadId },
      select: { id: true },
    });

    const memberIds = teamMembers.map(m => m.id);

    return this.prisma.material.findMany({
      where: {
        userId: { in: memberIds },
        status: 'PENDING_LEAD_APPROVAL',
      },
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
        createdAt: 'desc',
      },
    });
  }

  // Lead approves a material
  async leadApproveMaterial(materialId: string, leadId: string) {
    const lead = await this.prisma.user.findUnique({
      where: { id: leadId },
    });

    if (lead?.role !== 'LEAD') {
      throw new ForbiddenException('Only leads can approve materials');
    }

    const material = await this.prisma.material.findUnique({
      where: { id: materialId },
      include: { user: true },
    });

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    // Check if the material's creator is in this lead's team
    if (material.user.leadId !== leadId) {
      throw new ForbiddenException('You can only approve materials from your team members');
    }

    if (material.status !== 'PENDING_LEAD_APPROVAL') {
      throw new BadRequestException('Material is not pending approval');
    }

    return this.prisma.material.update({
      where: { id: materialId },
      data: {
        status: 'APPROVED_BY_LEAD',
        leadId: leadId,
        leadApprovedAt: new Date(),
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  // Lead rejects a material
  async leadRejectMaterial(materialId: string, leadId: string) {
    const lead = await this.prisma.user.findUnique({
      where: { id: leadId },
    });

    if (lead?.role !== 'LEAD') {
      throw new ForbiddenException('Only leads can reject materials');
    }

    const material = await this.prisma.material.findUnique({
      where: { id: materialId },
      include: { user: true },
    });

    if (!material) {
      throw new NotFoundException('Material not found');
    }

    if (material.user.leadId !== leadId) {
      throw new ForbiddenException('You can only reject materials from your team members');
    }

    if (material.status !== 'PENDING_LEAD_APPROVAL') {
      throw new BadRequestException('Material is not pending approval');
    }

    return this.prisma.material.update({
      where: { id: materialId },
      data: {
        status: 'REJECTED_BY_LEAD',
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  // Get approved materials available for batching (for leads)
  async getApprovedMaterials(leadId: string) {
    const lead = await this.prisma.user.findUnique({
      where: { id: leadId },
    });

    if (lead?.role !== 'LEAD') {
      throw new ForbiddenException('Only leads can view approved materials');
    }

    return this.prisma.material.findMany({
      where: {
        OR: [
          // Materials from their team members
          {
            user: { leadId: leadId },
            status: 'APPROVED_BY_LEAD',
            batchId: null,
          },
          // Materials created by the lead themselves
          {
            userId: leadId,
            status: 'APPROVED_BY_LEAD',
            batchId: null,
          },
        ],
      },
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
        leadApprovedAt: 'desc',
      },
    });
  }
}


import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBatchDto } from './dto/create-batch.dto';
import { AddMaterialsDto } from './dto/add-materials.dto';

@Injectable()
export class MaterialBatchService {
  constructor(private prisma: PrismaService) {}

  // Create a new batch (Lead only)
  async create(leadId: string, createBatchDto: CreateBatchDto) {
    const lead = await this.prisma.user.findUnique({
      where: { id: leadId },
    });

    if (lead?.role !== 'LEAD') {
      throw new ForbiddenException('Only leads can create batches');
    }

    if (!lead.companyId) {
      throw new BadRequestException('Lead must be part of a company');
    }

    return this.prisma.materialBatch.create({
      data: {
        ...createBatchDto,
        leadId,
        companyId: lead.companyId,
        status: 'DRAFT',
      },
      include: {
        lead: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        _count: {
          select: {
            materials: true,
          },
        },
      },
    });
  }

  // Add materials to a batch
  async addMaterials(batchId: string, leadId: string, addMaterialsDto: AddMaterialsDto) {
    const batch = await this.prisma.materialBatch.findUnique({
      where: { id: batchId },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    if (batch.leadId !== leadId) {
      throw new ForbiddenException('You can only add materials to your own batches');
    }

    if (batch.status !== 'DRAFT') {
      throw new BadRequestException('Can only add materials to draft batches');
    }

    // Verify all materials are approved and not already in a batch
    const materials = await this.prisma.material.findMany({
      where: {
        id: { in: addMaterialsDto.materialIds },
      },
      include: {
        user: true,
      },
    });

    if (materials.length !== addMaterialsDto.materialIds.length) {
      throw new NotFoundException('Some materials not found');
    }

    // Check each material
    for (const material of materials) {
      if (material.status !== 'APPROVED_BY_LEAD') {
        throw new BadRequestException(`Material ${material.name} is not approved by lead`);
      }

      if (material.batchId) {
        throw new BadRequestException(`Material ${material.name} is already in a batch`);
      }

      // Check if material is from this lead's team or created by the lead
      if (material.user.leadId !== leadId && material.userId !== leadId) {
        throw new ForbiddenException(`Material ${material.name} is not from your team`);
      }
    }

    // Add materials to batch
    await this.prisma.material.updateMany({
      where: {
        id: { in: addMaterialsDto.materialIds },
      },
      data: {
        batchId: batchId,
      },
    });

    return this.getBatchDetails(batchId);
  }

  // Remove materials from a batch
  async removeMaterials(batchId: string, leadId: string, addMaterialsDto: AddMaterialsDto) {
    const batch = await this.prisma.materialBatch.findUnique({
      where: { id: batchId },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    if (batch.leadId !== leadId) {
      throw new ForbiddenException('You can only remove materials from your own batches');
    }

    if (batch.status !== 'DRAFT') {
      throw new BadRequestException('Can only remove materials from draft batches');
    }

    await this.prisma.material.updateMany({
      where: {
        id: { in: addMaterialsDto.materialIds },
        batchId: batchId,
      },
      data: {
        batchId: null,
      },
    });

    return this.getBatchDetails(batchId);
  }

  // Submit batch for admin approval
  async submitBatch(batchId: string, leadId: string) {
    const batch = await this.prisma.materialBatch.findUnique({
      where: { id: batchId },
      include: {
        materials: true,
      },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    if (batch.leadId !== leadId) {
      throw new ForbiddenException('You can only submit your own batches');
    }

    if (batch.status !== 'DRAFT') {
      throw new BadRequestException('Batch is not in draft status');
    }

    if (batch.materials.length === 0) {
      throw new BadRequestException('Cannot submit empty batch');
    }

    const updatedBatch = await this.prisma.materialBatch.update({
      where: { id: batchId },
      data: {
        status: 'SUBMITTED',
        submittedAt: new Date(),
      },
      include: {
        lead: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        materials: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
        },
      },
    });

    // Update all materials in batch to PENDING_ADMIN_APPROVAL
    await this.prisma.material.updateMany({
      where: {
        batchId: batchId,
      },
      data: {
        status: 'PENDING_ADMIN_APPROVAL',
      },
    });

    return updatedBatch;
  }

  // Get lead's batches
  async getMyBatches(leadId: string) {
    const lead = await this.prisma.user.findUnique({
      where: { id: leadId },
    });

    if (lead?.role !== 'LEAD') {
      throw new ForbiddenException('Only leads can view batches');
    }

    return this.prisma.materialBatch.findMany({
      where: {
        leadId: leadId,
      },
      include: {
        _count: {
          select: {
            materials: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  // Get batch details
  async getBatchDetails(batchId: string) {
    const batch = await this.prisma.materialBatch.findUnique({
      where: { id: batchId },
      include: {
        lead: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        reviewer: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        materials: {
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
        },
      },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    return batch;
  }

  // Delete a draft batch
  async deleteBatch(batchId: string, leadId: string) {
    const batch = await this.prisma.materialBatch.findUnique({
      where: { id: batchId },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    if (batch.leadId !== leadId) {
      throw new ForbiddenException('You can only delete your own batches');
    }

    if (batch.status !== 'DRAFT') {
      throw new BadRequestException('Can only delete draft batches');
    }

    // Remove batch reference from materials
    await this.prisma.material.updateMany({
      where: {
        batchId: batchId,
      },
      data: {
        batchId: null,
      },
    });

    await this.prisma.materialBatch.delete({
      where: { id: batchId },
    });

    return { message: 'Batch deleted successfully' };
  }

  // Admin: Get pending batches
  async getPendingBatches(adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (admin?.role !== 'ADMIN') {
      throw new ForbiddenException('Only admins can view pending batches');
    }

    if (!admin.companyId) {
      throw new BadRequestException('Admin must be part of a company');
    }

    return this.prisma.materialBatch.findMany({
      where: {
        companyId: admin.companyId,
        status: 'SUBMITTED',
      },
      include: {
        lead: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        _count: {
          select: {
            materials: true,
          },
        },
      },
      orderBy: {
        submittedAt: 'asc',
      },
    });
  }

  // Admin: Approve batch
  async approveBatch(batchId: string, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (admin?.role !== 'ADMIN') {
      throw new ForbiddenException('Only admins can approve batches');
    }

    const batch = await this.prisma.materialBatch.findUnique({
      where: { id: batchId },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    if (batch.companyId !== admin.companyId) {
      throw new ForbiddenException('You can only approve batches from your company');
    }

    if (batch.status !== 'SUBMITTED') {
      throw new BadRequestException('Batch is not pending approval');
    }

    // Update batch status
    const updatedBatch = await this.prisma.materialBatch.update({
      where: { id: batchId },
      data: {
        status: 'APPROVED',
        reviewedAt: new Date(),
        reviewedBy: adminId,
      },
      include: {
        lead: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        reviewer: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        materials: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
        },
      },
    });

    // Update all materials in batch to APPROVED_BY_ADMIN
    await this.prisma.material.updateMany({
      where: {
        batchId: batchId,
      },
      data: {
        status: 'APPROVED_BY_ADMIN',
      },
    });

    return updatedBatch;
  }

  // Admin: Reject batch
  async rejectBatch(batchId: string, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (admin?.role !== 'ADMIN') {
      throw new ForbiddenException('Only admins can reject batches');
    }

    const batch = await this.prisma.materialBatch.findUnique({
      where: { id: batchId },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    if (batch.companyId !== admin.companyId) {
      throw new ForbiddenException('You can only reject batches from your company');
    }

    if (batch.status !== 'SUBMITTED') {
      throw new BadRequestException('Batch is not pending approval');
    }

    // Update batch status
    const updatedBatch = await this.prisma.materialBatch.update({
      where: { id: batchId },
      data: {
        status: 'REJECTED',
        reviewedAt: new Date(),
        reviewedBy: adminId,
      },
      include: {
        lead: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        reviewer: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    // Update all materials in batch to REJECTED_BY_ADMIN and remove from batch
    await this.prisma.material.updateMany({
      where: {
        batchId: batchId,
      },
      data: {
        status: 'REJECTED_BY_ADMIN',
        batchId: null,
      },
    });

    return updatedBatch;
  }

  // Get all batches for company (admin view)
  async getAllBatches(adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (admin?.role !== 'ADMIN') {
      throw new ForbiddenException('Only admins can view all batches');
    }

    if (!admin.companyId) {
      throw new BadRequestException('Admin must be part of a company');
    }

    return this.prisma.materialBatch.findMany({
      where: {
        companyId: admin.companyId,
      },
      include: {
        lead: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        reviewer: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        _count: {
          select: {
            materials: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }
}


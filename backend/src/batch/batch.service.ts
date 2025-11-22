import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBatchDto } from './dto/create-batch.dto';
import { UpdateBatchDto } from './dto/update-batch.dto';
import { BatchStatus } from '@prisma/client';

@Injectable()
export class BatchService {
  constructor(private prisma: PrismaService) {}

  async create(leadId: string, createBatchDto: CreateBatchDto) {
    // Verify user is a lead
    const lead = await this.prisma.user.findUnique({
      where: { id: leadId },
    });

    if (!lead || lead.role !== 'LEAD') {
      throw new ForbiddenException('Only leads can create batches');
    }

    if (!lead.companyId) {
      throw new BadRequestException('Lead must be part of a company');
    }

    // Verify all materials exist and are approved by this lead
    const materials = await this.prisma.material.findMany({
      where: {
        id: { in: createBatchDto.materialIds },
      },
      include: {
        user: true,
      },
    });

    if (materials.length !== createBatchDto.materialIds.length) {
      throw new NotFoundException('Some materials were not found');
    }

    // Verify all materials are approved and belong to this lead's team or the lead themselves
    for (const material of materials) {
      if (material.status !== 'APPROVED_BY_LEAD') {
        throw new BadRequestException(
          `Material "${material.name}" is not approved by lead`,
        );
      }

      if (material.batchId) {
        throw new BadRequestException(
          `Material "${material.name}" is already in a batch`,
        );
      }

      // Check if material is from lead's team or created by lead
      const isFromTeam = material.user.leadId === leadId;
      const isCreatedByLead = material.userId === leadId;

      if (!isFromTeam && !isCreatedByLead) {
        throw new ForbiddenException(
          `Material "${material.name}" is not from your team`,
        );
      }
    }

    // Create batch
    const batch = await this.prisma.materialBatch.create({
      data: {
        name: createBatchDto.name,
        description: createBatchDto.description,
        leadId,
        companyId: lead.companyId,
        status: BatchStatus.DRAFT,
      },
      include: {
        lead: {
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

    // Assign materials to batch
    await this.prisma.material.updateMany({
      where: {
        id: { in: createBatchDto.materialIds },
      },
      data: {
        batchId: batch.id,
        status: 'PENDING_ADMIN_APPROVAL',
      },
    });

    // Fetch batch with materials
    return this.findOne(batch.id, leadId);
  }

  async findAll(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || !user.companyId) {
      return [];
    }

    // Admins see all batches, leads see only their batches
    const where: any = {
      companyId: user.companyId,
    };

    if (user.role === 'LEAD') {
      where.leadId = userId;
    }

    return this.prisma.materialBatch.findMany({
      where,
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

  async findOne(id: string, userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    const batch = await this.prisma.materialBatch.findUnique({
      where: { id },
      include: {
        lead: {
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
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    // Check access: must be from same company
    if (batch.companyId !== user?.companyId) {
      throw new ForbiddenException('You can only view batches from your company');
    }

    return batch;
  }

  async update(id: string, userId: string, updateBatchDto: UpdateBatchDto) {
    const batch = await this.prisma.materialBatch.findUnique({
      where: { id },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    // Only the lead who created it can update, and only if it's in DRAFT status
    if (batch.leadId !== userId) {
      throw new ForbiddenException('You can only update your own batches');
    }

    if (batch.status !== BatchStatus.DRAFT) {
      throw new BadRequestException('Only draft batches can be updated');
    }

    // If updating materials, verify them
    if (updateBatchDto.materialIds) {
      const materials = await this.prisma.material.findMany({
        where: {
          id: { in: updateBatchDto.materialIds },
        },
        include: {
          user: true,
        },
      });

      if (materials.length !== updateBatchDto.materialIds.length) {
        throw new NotFoundException('Some materials were not found');
      }

      // Verify all materials are approved and from this lead's team
      for (const material of materials) {
        if (material.status !== 'APPROVED_BY_LEAD') {
          throw new BadRequestException(
            `Material "${material.name}" is not approved by lead`,
          );
        }

        if (material.batchId && material.batchId !== id) {
          throw new BadRequestException(
            `Material "${material.name}" is already in another batch`,
          );
        }

        const isFromTeam = material.user.leadId === userId;
        const isCreatedByLead = material.userId === userId;

        if (!isFromTeam && !isCreatedByLead) {
          throw new ForbiddenException(
            `Material "${material.name}" is not from your team`,
          );
        }
      }

      // Remove old materials from batch
      await this.prisma.material.updateMany({
        where: {
          batchId: id,
        },
        data: {
          batchId: null,
          status: 'APPROVED_BY_LEAD',
        },
      });

      // Add new materials to batch
      await this.prisma.material.updateMany({
        where: {
          id: { in: updateBatchDto.materialIds },
        },
        data: {
          batchId: id,
          status: 'PENDING_ADMIN_APPROVAL',
        },
      });
    }

    // Update batch
    const updated = await this.prisma.materialBatch.update({
      where: { id },
      data: {
        name: updateBatchDto.name,
        description: updateBatchDto.description,
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
        _count: {
          select: {
            materials: true,
          },
        },
      },
    });

    return updated;
  }

  async remove(id: string, userId: string) {
    const batch = await this.prisma.materialBatch.findUnique({
      where: { id },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    // Only the lead who created it can delete, and only if it's in DRAFT status
    if (batch.leadId !== userId) {
      throw new ForbiddenException('You can only delete your own batches');
    }

    if (batch.status !== BatchStatus.DRAFT) {
      throw new BadRequestException('Only draft batches can be deleted');
    }

    // Remove materials from batch
    await this.prisma.material.updateMany({
      where: {
        batchId: id,
      },
      data: {
        batchId: null,
        status: 'APPROVED_BY_LEAD',
      },
    });

    // Delete batch
    await this.prisma.materialBatch.delete({
      where: { id },
    });

    return { message: 'Batch deleted successfully' };
  }

  async submitBatch(id: string, userId: string) {
    const batch = await this.prisma.materialBatch.findUnique({
      where: { id },
      include: {
        materials: true,
      },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    if (batch.leadId !== userId) {
      throw new ForbiddenException('You can only submit your own batches');
    }

    if (batch.status !== BatchStatus.DRAFT) {
      throw new BadRequestException('Only draft batches can be submitted');
    }

    if (batch.materials.length === 0) {
      throw new BadRequestException('Cannot submit empty batch');
    }

    const updated = await this.prisma.materialBatch.update({
      where: { id },
      data: {
        status: BatchStatus.SUBMITTED,
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
        _count: {
          select: {
            materials: true,
          },
        },
      },
    });

    return updated;
  }

  async getPendingBatches(adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (!admin || admin.role !== 'ADMIN') {
      throw new ForbiddenException('Only admins can view pending batches');
    }

    if (!admin.companyId) {
      throw new BadRequestException('Admin must be part of a company');
    }

    return this.prisma.materialBatch.findMany({
      where: {
        companyId: admin.companyId,
        status: BatchStatus.SUBMITTED,
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

  async approveBatch(id: string, adminId: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (!admin || admin.role !== 'ADMIN') {
      throw new ForbiddenException('Only admins can approve batches');
    }

    const batch = await this.prisma.materialBatch.findUnique({
      where: { id },
      include: {
        materials: true,
      },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    if (batch.companyId !== admin.companyId) {
      throw new ForbiddenException('You can only approve batches from your company');
    }

    if (batch.status !== BatchStatus.SUBMITTED) {
      throw new BadRequestException('Only submitted batches can be approved');
    }

    // Update batch status
    const updated = await this.prisma.materialBatch.update({
      where: { id },
      data: {
        status: BatchStatus.APPROVED,
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
    });

    // Update all materials in batch to approved
    await this.prisma.material.updateMany({
      where: {
        batchId: id,
      },
      data: {
        status: 'APPROVED_BY_ADMIN',
      },
    });

    return updated;
  }

  async rejectBatch(id: string, adminId: string, reason?: string) {
    const admin = await this.prisma.user.findUnique({
      where: { id: adminId },
    });

    if (!admin || admin.role !== 'ADMIN') {
      throw new ForbiddenException('Only admins can reject batches');
    }

    const batch = await this.prisma.materialBatch.findUnique({
      where: { id },
      include: {
        materials: true,
      },
    });

    if (!batch) {
      throw new NotFoundException('Batch not found');
    }

    if (batch.companyId !== admin.companyId) {
      throw new ForbiddenException('You can only reject batches from your company');
    }

    if (batch.status !== BatchStatus.SUBMITTED) {
      throw new BadRequestException('Only submitted batches can be rejected');
    }

    // Update batch status
    const updated = await this.prisma.materialBatch.update({
      where: { id },
      data: {
        status: BatchStatus.REJECTED,
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
    });

    // Update all materials in batch to rejected and remove from batch
    await this.prisma.material.updateMany({
      where: {
        batchId: id,
      },
      data: {
        status: 'REJECTED_BY_ADMIN',
        batchId: null,
      },
    });

    return updated;
  }
}


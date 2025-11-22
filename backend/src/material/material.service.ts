import {
  Injectable,
  NotFoundException,
  ForbiddenException,
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

    return this.prisma.material.create({
      data: {
        ...createMaterialDto,
        userId,
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

  // Admin can approve/reject materials
  async updateStatus(id: string, userId: string, status: 'APPROVED' | 'REJECTED') {
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
}


import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { GrantPermissionDto } from './dto/grant-permission.dto';
import { UserType, PermissionScope } from '@prisma/client';

@Injectable()
export class PermissionsService {
  constructor(private prisma: PrismaService) {}

  // =====================================================
  // GRANT & REVOKE PERMISSIONS
  // =====================================================

  async grantPermission(dto: GrantPermissionDto, granterId: string) {
    // Verify the granter is an OWNER
    const granter = await this.prisma.user.findUnique({
      where: { id: granterId },
    });

    if (!granter || granter.userType !== UserType.OWNER) {
      throw new ForbiddenException('Only owners can grant permissions');
    }

    // Verify the admin exists and is part of the same company
    const admin = await this.prisma.user.findUnique({
      where: { id: dto.adminId },
    });

    if (!admin || admin.companyId !== granter.companyId) {
      throw new NotFoundException('Admin not found in your company');
    }

    if (admin.userType !== UserType.ADMIN) {
      throw new BadRequestException('User must be an ADMIN to receive permissions');
    }

    // Validate scope-specific IDs
    if (dto.permissionScope === PermissionScope.SMART_GROUP && !dto.smartGroupId) {
      throw new BadRequestException('Smart group ID required for SMART_GROUP scope');
    }

    if (dto.permissionScope === PermissionScope.ORG_UNIT && !dto.orgUnitId) {
      throw new BadRequestException('Org unit ID required for ORG_UNIT scope');
    }

    // Create or update permission
    const existing = await this.prisma.adminPermission.findFirst({
      where: {
        adminId: dto.adminId,
        featureType: dto.featureType,
        permissionScope: dto.permissionScope,
        smartGroupId: dto.smartGroupId || null,
        orgUnitId: dto.orgUnitId || null,
      },
    });

    if (existing) {
      return this.prisma.adminPermission.update({
        where: { id: existing.id },
        data: {
          accessLevel: dto.accessLevel,
          deepPermissions: dto.deepPermissions || undefined,
        },
      });
    }

    return this.prisma.adminPermission.create({
      data: {
        adminId: dto.adminId,
        featureType: dto.featureType,
        accessLevel: dto.accessLevel,
        permissionScope: dto.permissionScope,
        smartGroupId: dto.smartGroupId,
        orgUnitId: dto.orgUnitId,
        deepPermissions: dto.deepPermissions,
      },
    });
  }

  async revokePermission(permissionId: string, revokerId: string) {
    // Verify the revoker is an OWNER
    const revoker = await this.prisma.user.findUnique({
      where: { id: revokerId },
    });

    if (!revoker || revoker.userType !== UserType.OWNER) {
      throw new ForbiddenException('Only owners can revoke permissions');
    }

    const permission = await this.prisma.adminPermission.findUnique({
      where: { id: permissionId },
      include: { admin: true },
    });

    if (!permission) {
      throw new NotFoundException('Permission not found');
    }

    if (permission.admin.companyId !== revoker.companyId) {
      throw new ForbiddenException('Cannot revoke permissions from another company');
    }

    await this.prisma.adminPermission.delete({
      where: { id: permissionId },
    });

    return { message: 'Permission revoked successfully' };
  }

  // =====================================================
  // QUERY PERMISSIONS
  // =====================================================

  async getUserPermissions(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        adminPermissions: {
          include: {
            smartGroup: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // OWNERs have full access to everything
    if (user.userType === UserType.OWNER) {
      return {
        userType: UserType.OWNER,
        hasFullAccess: true,
        permissions: [],
      };
    }

    // ADMINs have custom permissions
    if (user.userType === UserType.ADMIN) {
      return {
        userType: UserType.ADMIN,
        hasFullAccess: false,
        permissions: user.adminPermissions,
      };
    }

    // Regular USERs have no admin permissions
    return {
      userType: UserType.USER,
      hasFullAccess: false,
      permissions: [],
    };
  }

  async getAdminsWithPermissions(companyId: string, requesterId: string) {
    // Verify requester is an OWNER
    const requester = await this.prisma.user.findUnique({
      where: { id: requesterId },
    });

    if (!requester || requester.companyId !== companyId || requester.userType !== UserType.OWNER) {
      throw new ForbiddenException('Only owners can view admin permissions');
    }

    return this.prisma.user.findMany({
      where: {
        companyId,
        userType: UserType.ADMIN,
      },
      select: {
        id: true,
        name: true,
        email: true,
        adminPermissions: {
          include: {
            smartGroup: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
      orderBy: {
        name: 'asc',
      },
    });
  }

  // =====================================================
  // PERMISSION CHECKING HELPERS
  // =====================================================

  async canUserAccessFeature(
    userId: string,
    featureType: any,
    requiredLevel: any,
  ): Promise<boolean> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        adminPermissions: {
          where: {
            featureType,
          },
        },
      },
    });

    if (!user) return false;

    // OWNERs have full access
    if (user.userType === UserType.OWNER) return true;

    // Check ADMIN permissions
    if (user.userType === UserType.ADMIN) {
      const accessLevelOrder = ['VIEW', 'EDIT', 'MANAGE', 'FULL'];
      return user.adminPermissions.some(perm => {
        const permLevel = accessLevelOrder.indexOf(perm.accessLevel);
        const reqLevel = accessLevelOrder.indexOf(requiredLevel);
        return permLevel >= reqLevel;
      });
    }

    return false;
  }
}

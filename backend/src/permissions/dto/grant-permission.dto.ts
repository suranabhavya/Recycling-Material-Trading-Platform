import { IsEnum, IsNotEmpty, IsOptional, IsString, ValidateIf } from 'class-validator';
import { FeatureType, AccessLevel, PermissionScope } from '@prisma/client';

export class GrantPermissionDto {
  @IsNotEmpty()
  @IsString()
  adminId: string;

  @IsNotEmpty()
  @IsEnum(FeatureType)
  featureType: FeatureType;

  @IsNotEmpty()
  @IsEnum(AccessLevel)
  accessLevel: AccessLevel;

  @IsNotEmpty()
  @IsEnum(PermissionScope)
  permissionScope: PermissionScope;

  @ValidateIf(o => o.permissionScope === PermissionScope.SMART_GROUP)
  @IsNotEmpty()
  @IsString()
  smartGroupId?: string;

  @ValidateIf(o => o.permissionScope === PermissionScope.ORG_UNIT)
  @IsNotEmpty()
  @IsString()
  orgUnitId?: string;

  @IsOptional()
  deepPermissions?: Record<string, any>;
}

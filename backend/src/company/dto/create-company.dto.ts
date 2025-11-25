import { IsEmail, IsEnum, IsNotEmpty, IsOptional, IsString, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { CompanyType, HierarchyMode } from '@prisma/client';
import { CreateRoleTemplateDto } from '../../hierarchy/dto/create-role-template.dto';
import { CreateOrgUnitDto } from '../../hierarchy/dto/create-org-unit.dto';

export class CreateCompanyDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @IsOptional()
  phone?: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsEnum(CompanyType)
  type: CompanyType;

  @IsEnum(HierarchyMode)
  hierarchyMode: HierarchyMode;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateRoleTemplateDto)
  roleTemplates: CreateRoleTemplateDto[];

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrgUnitDto)
  orgUnits?: CreateOrgUnitDto[];
}


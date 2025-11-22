import { IsEnum, IsOptional, IsString } from 'class-validator';
import { MaterialStatus } from '@prisma/client';

export class QueryMaterialDto {
  @IsOptional()
  @IsEnum(MaterialStatus)
  status?: MaterialStatus;

  @IsOptional()
  @IsString()
  userId?: string;

  @IsOptional()
  @IsString()
  leadId?: string;

  @IsOptional()
  @IsString()
  companyId?: string;
}


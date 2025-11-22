import { IsEnum, IsOptional, IsString } from 'class-validator';
import { MaterialStatus } from '@prisma/client';

export class ApproveMaterialDto {
  @IsEnum(MaterialStatus)
  status: MaterialStatus;

  @IsOptional()
  @IsString()
  rejectionReason?: string;
}


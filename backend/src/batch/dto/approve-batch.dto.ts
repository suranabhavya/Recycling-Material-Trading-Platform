import { IsEnum, IsOptional, IsString } from 'class-validator';
import { BatchStatus } from '@prisma/client';

export class ApproveBatchDto {
  @IsEnum(BatchStatus)
  status: BatchStatus;

  @IsOptional()
  @IsString()
  rejectionReason?: string;
}


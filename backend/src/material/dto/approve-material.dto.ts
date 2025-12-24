import { IsEnum, IsOptional, IsString } from 'class-validator';
import { ApprovalAction } from '@prisma/client';

export class ApproveMaterialDto {
  @IsEnum(ApprovalAction)
  action: ApprovalAction;

  @IsOptional()
  @IsString()
  comments?: string;
}

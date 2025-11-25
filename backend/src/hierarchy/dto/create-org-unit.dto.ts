import { IsString, IsOptional, IsObject } from 'class-validator';

export class CreateOrgUnitDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  parentId?: string;

  @IsOptional()
  @IsObject()
  metadata?: Record<string, any>;
}

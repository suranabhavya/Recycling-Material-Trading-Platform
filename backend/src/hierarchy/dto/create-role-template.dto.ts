import { IsString, IsInt, IsBoolean, IsObject, IsOptional, Min } from 'class-validator';

export class CreateRoleTemplateDto {
  @IsString()
  name: string;

  @IsInt()
  @Min(1)
  level: number;

  @IsObject()
  permissions: Record<string, any>;

  @IsBoolean()
  requiresApproval: boolean;

  @IsOptional()
  @IsString()
  description?: string;
}

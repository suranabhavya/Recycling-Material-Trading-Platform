import { IsBoolean, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateSmartGroupDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  criteria?: Record<string, any>; // { directManagerId: "xyz", roleId: "abc" }

  @IsOptional()
  @IsBoolean()
  isManual?: boolean; // If true, members are manually assigned
}

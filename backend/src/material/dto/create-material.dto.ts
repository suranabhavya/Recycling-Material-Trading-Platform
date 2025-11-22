import { IsString, IsNumber, IsOptional, IsArray, Min } from 'class-validator';

export class CreateMaterialDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNumber()
  @Min(0)
  quantity: number;

  @IsString()
  unit: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  price?: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  images?: string[];
}


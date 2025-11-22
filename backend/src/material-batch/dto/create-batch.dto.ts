import { IsString, IsOptional } from 'class-validator';

export class CreateBatchDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;
}


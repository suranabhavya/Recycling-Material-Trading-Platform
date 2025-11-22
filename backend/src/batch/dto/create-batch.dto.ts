import { IsString, IsOptional, IsArray, ArrayMinSize } from 'class-validator';

export class CreateBatchDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsArray()
  @ArrayMinSize(1, { message: 'Batch must contain at least one material' })
  @IsString({ each: true })
  materialIds: string[];
}


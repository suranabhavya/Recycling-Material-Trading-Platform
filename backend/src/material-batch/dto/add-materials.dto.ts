import { IsArray, IsString } from 'class-validator';

export class AddMaterialsDto {
  @IsArray()
  @IsString({ each: true })
  materialIds: string[];
}


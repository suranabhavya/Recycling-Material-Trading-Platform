import { IsNotEmpty, IsString } from 'class-validator';

export class AssignManagerDto {
  @IsNotEmpty()
  @IsString()
  userId: string;

  @IsNotEmpty()
  @IsString()
  managerId: string;
}

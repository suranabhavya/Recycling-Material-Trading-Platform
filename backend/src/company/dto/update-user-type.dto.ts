import { IsEnum, IsNotEmpty, IsString } from 'class-validator';
import { UserType } from '@prisma/client';

export class UpdateUserTypeDto {
  @IsNotEmpty()
  @IsString()
  userId: string;

  @IsNotEmpty()
  @IsEnum(UserType)
  userType: UserType;
}

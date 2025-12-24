import { IsEmail, IsNotEmpty, IsString, MinLength, IsOptional } from 'class-validator';

export class RegisterCompanyDto {
  // User Information
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  password: string;

  @IsString()
  @IsNotEmpty()
  firstName: string;

  @IsString()
  @IsNotEmpty()
  lastName: string;

  // Company Information
  @IsString()
  @IsNotEmpty()
  companyName: string;

  @IsOptional()
  @IsEmail()
  companyEmail?: string;

  @IsOptional()
  @IsString()
  companyPhone?: string;

  @IsOptional()
  @IsString()
  companyAddress?: string;

  // Business Industry
  @IsString()
  @IsNotEmpty()
  industry: string;

  @IsOptional()
  @IsString()
  subtype?: string;
}

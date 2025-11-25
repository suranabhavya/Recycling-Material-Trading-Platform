import { PartialType } from '@nestjs/mapped-types';
import { CreateRoleTemplateDto } from './create-role-template.dto';

export class UpdateRoleTemplateDto extends PartialType(CreateRoleTemplateDto) {}

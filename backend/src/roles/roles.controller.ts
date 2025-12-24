import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { RolesService } from './roles.service';
import { CreateRoleDto } from './dto/create-role.dto';
import { JwtAuthGuard } from '../auth/strategies/jwt-auth.guard';

@Controller('roles')
@UseGuards(JwtAuthGuard)
export class RolesController {
  constructor(private readonly rolesService: RolesService) {}

  @Post('company/:companyId')
  create(
    @Param('companyId') companyId: string,
    @Body() dto: CreateRoleDto,
    @Request() req,
  ) {
    return this.rolesService.create(companyId, dto, req.user.userId);
  }

  @Get('company/:companyId')
  findAll(@Param('companyId') companyId: string) {
    return this.rolesService.findAll(companyId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.rolesService.findOne(id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() dto: CreateRoleDto, @Request() req) {
    return this.rolesService.update(id, dto, req.user.userId);
  }

  @Delete(':id')
  delete(@Param('id') id: string, @Request() req) {
    return this.rolesService.delete(id, req.user.userId);
  }

  @Put('assign/:userId/:roleId')
  assignRoleToUser(
    @Param('userId') userId: string,
    @Param('roleId') roleId: string,
    @Request() req,
  ) {
    return this.rolesService.assignRoleToUser(userId, roleId, req.user.userId);
  }
}

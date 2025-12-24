import {
  Controller,
  Get,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { UsersService } from './users.service';

@Controller('users')
@UseGuards(AuthGuard('jwt'))
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('company/:companyId')
  getCompanyUsers(@Param('companyId') companyId: string) {
    return this.usersService.getCompanyUsers(companyId);
  }

  @Get('branch/:branchId')
  getUsersByBranch(@Param('branchId') branchId: string) {
    return this.usersService.getUsersByBranch(branchId);
  }

  @Get(':id')
  getUserById(@Param('id') id: string) {
    return this.usersService.getUserById(id);
  }

  @Put(':id')
  updateUser(@Param('id') id: string, @Body() data: any) {
    return this.usersService.updateUser(id, data);
  }

  @Put(':id/manager')
  assignManager(
    @Param('id') id: string,
    @Body('directManagerId') managerId: string | null,
  ) {
    return this.usersService.assignManager(id, managerId);
  }

  @Put(':id/branch')
  assignBranch(@Param('id') id: string, @Body('branchId') branchId: string) {
    return this.usersService.assignBranch(id, branchId);
  }

  @Put(':id/role')
  assignRole(@Param('id') id: string, @Body('roleId') roleId: string | null) {
    return this.usersService.assignRole(id, roleId);
  }

  @Delete(':id')
  deleteUser(@Param('id') id: string) {
    return this.usersService.deleteUser(id);
  }
}

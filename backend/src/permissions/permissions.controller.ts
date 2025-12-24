import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { PermissionsService } from './permissions.service';
import { GrantPermissionDto } from './dto/grant-permission.dto';
import { JwtAuthGuard } from '../auth/strategies/jwt-auth.guard';

@Controller('permissions')
@UseGuards(JwtAuthGuard)
export class PermissionsController {
  constructor(private readonly permissionsService: PermissionsService) {}

  @Post()
  grantPermission(@Body() dto: GrantPermissionDto, @Request() req) {
    return this.permissionsService.grantPermission(dto, req.user.userId);
  }

  @Delete(':permissionId')
  revokePermission(@Param('permissionId') permissionId: string, @Request() req) {
    return this.permissionsService.revokePermission(permissionId, req.user.userId);
  }

  @Get('user/:userId')
  getUserPermissions(@Param('userId') userId: string) {
    return this.permissionsService.getUserPermissions(userId);
  }

  @Get('company/:companyId/admins')
  getAdminsWithPermissions(@Param('companyId') companyId: string, @Request() req) {
    return this.permissionsService.getAdminsWithPermissions(companyId, req.user.userId);
  }
}

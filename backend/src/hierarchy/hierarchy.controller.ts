import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { HierarchyService } from './hierarchy.service';
import { CreateRoleTemplateDto } from './dto/create-role-template.dto';
import { UpdateRoleTemplateDto } from './dto/update-role-template.dto';
import { CreateOrgUnitDto } from './dto/create-org-unit.dto';
import { UpdateOrgUnitDto } from './dto/update-org-unit.dto';

@Controller('hierarchy')
@UseGuards(AuthGuard('jwt'))
export class HierarchyController {
  constructor(private hierarchyService: HierarchyService) {}

  @Post('role-templates')
  createRoleTemplate(@Request() req, @Body() dto: CreateRoleTemplateDto) {
    return this.hierarchyService.createRoleTemplate(req.user.companyId, dto);
  }

  @Get('role-templates')
  getRoleTemplates(@Request() req) {
    return this.hierarchyService.getRoleTemplates(req.user.companyId);
  }

  @Get('role-templates/:id')
  getRoleTemplate(@Param('id') id: string) {
    return this.hierarchyService.getRoleTemplate(id);
  }

  @Put('role-templates/:id')
  updateRoleTemplate(@Param('id') id: string, @Body() dto: UpdateRoleTemplateDto) {
    return this.hierarchyService.updateRoleTemplate(id, dto);
  }

  @Delete('role-templates/:id')
  deleteRoleTemplate(@Param('id') id: string) {
    return this.hierarchyService.deleteRoleTemplate(id);
  }

  @Post('org-units')
  createOrgUnit(@Request() req, @Body() dto: CreateOrgUnitDto) {
    return this.hierarchyService.createOrgUnit(req.user.companyId, dto);
  }

  @Get('org-units')
  getOrgUnits(@Request() req) {
    return this.hierarchyService.getOrgUnits(req.user.companyId);
  }

  @Get('org-units/tree')
  getOrgTree(@Request() req) {
    return this.hierarchyService.getOrgTree(req.user.companyId);
  }

  @Get('org-units/:id')
  getOrgUnit(@Param('id') id: string) {
    return this.hierarchyService.getOrgUnit(id);
  }

  @Put('org-units/:id')
  updateOrgUnit(@Param('id') id: string, @Body() dto: UpdateOrgUnitDto) {
    return this.hierarchyService.updateOrgUnit(id, dto);
  }

  @Delete('org-units/:id')
  deleteOrgUnit(@Param('id') id: string) {
    return this.hierarchyService.deleteOrgUnit(id);
  }

  @Get('approval-chain')
  getApprovalChain(@Request() req) {
    return this.hierarchyService.getApprovalChainLevels(req.user.id);
  }
}

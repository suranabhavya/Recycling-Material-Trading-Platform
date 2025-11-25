import { Controller, Get, Post, Body, Param, UseGuards, Request, Patch } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { CompanyService } from './company.service';
import { CreateCompanyDto } from './dto/create-company.dto';
import { JoinCompanyDto } from './dto/join-company.dto';

@Controller('companies')
export class CompanyController {
  constructor(private companyService: CompanyService) {}

  @Get()
  findAll() {
    return this.companyService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.companyService.findOne(id);
  }

  @Post()
  @UseGuards(AuthGuard('jwt'))
  create(@Body() createCompanyDto: CreateCompanyDto, @Request() req: { user: any }) {
    return this.companyService.create(createCompanyDto, req.user.id);
  }

  @Post('join')
  @UseGuards(AuthGuard('jwt'))
  join(@Body() joinCompanyDto: JoinCompanyDto, @Request() req: { user: any }) {
    return this.companyService.joinCompany(joinCompanyDto, req.user.id);
  }

  @Get(':id/pending-approvals')
  @UseGuards(AuthGuard('jwt'))
  getPendingApprovals(@Param('id') id: string) {
    return this.companyService.getPendingApprovals(id);
  }

  @Post('approve/:userId')
  @UseGuards(AuthGuard('jwt'))
  approveUser(@Param('userId') userId: string, @Request() req: { user: any }) {
    return this.companyService.approveUser(userId, req.user.id);
  }

  @Post('reject/:userId')
  @UseGuards(AuthGuard('jwt'))
  rejectUser(@Param('userId') userId: string, @Request() req: { user: any }) {
    return this.companyService.rejectUser(userId, req.user.id);
  }

  @Get(':id/members')
  @UseGuards(AuthGuard('jwt'))
  getCompanyMembers(@Param('id') id: string) {
    return this.companyService.getCompanyMembers(id);
  }

  @Patch('update-role/:userId')
  @UseGuards(AuthGuard('jwt'))
  updateUserRole(
    @Param('userId') userId: string,
    @Body('roleTemplateId') roleTemplateId: string,
    @Request() req: { user: any },
  ) {
    return this.companyService.updateUserRole(userId, roleTemplateId, req.user.id);
  }

  @Post('kick/:userId')
  @UseGuards(AuthGuard('jwt'))
  kickMember(@Param('userId') userId: string, @Request() req: { user: any }) {
    return this.companyService.kickMember(userId, req.user.id);
  }

  @Patch('assign-manager')
  @UseGuards(AuthGuard('jwt'))
  assignManager(
    @Body('userId') userId: string,
    @Body('managerId') managerId: string,
    @Request() req: { user: any },
  ) {
    return this.companyService.assignManager(userId, managerId, req.user.id);
  }

  @Patch('assign-org-unit')
  @UseGuards(AuthGuard('jwt'))
  assignOrgUnit(
    @Body('userId') userId: string,
    @Body('orgUnitId') orgUnitId: string,
    @Body('isOrgUnitHead') isOrgUnitHead: boolean,
    @Request() req: { user: any },
  ) {
    return this.companyService.assignOrgUnit(userId, orgUnitId, req.user.id, isOrgUnitHead);
  }

  @Get('subordinates/me')
  @UseGuards(AuthGuard('jwt'))
  getMySubordinates(@Request() req: { user: any }) {
    return this.companyService.getSubordinates(req.user.id);
  }

  @Get(':id/hierarchy')
  @UseGuards(AuthGuard('jwt'))
  getCompanyHierarchy(@Param('id') id: string) {
    return this.companyService.getCompanyHierarchy(id);
  }
}

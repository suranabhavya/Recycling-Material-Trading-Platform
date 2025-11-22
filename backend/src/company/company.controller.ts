import { Controller, Get, Post, Body, Param, UseGuards, Request, Patch } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { CompanyService } from './company.service';
import { CreateCompanyDto } from './dto/create-company.dto';
import { JoinCompanyDto } from './dto/join-company.dto';
import { UserRole } from '@prisma/client';

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
    @Body('role') role: UserRole,
    @Request() req: { user: any },
  ) {
    return this.companyService.updateUserRole(userId, role, req.user.id);
  }

  @Post('kick/:userId')
  @UseGuards(AuthGuard('jwt'))
  kickMember(@Param('userId') userId: string, @Request() req: { user: any }) {
    return this.companyService.kickMember(userId, req.user.id);
  }

  // Assign a lead to a member
  @Patch('assign-lead/:memberId')
  @UseGuards(AuthGuard('jwt'))
  assignLead(
    @Param('memberId') memberId: string,
    @Body('leadId') leadId: string,
    @Request() req: { user: any },
  ) {
    return this.companyService.assignLead(memberId, leadId, req.user.id);
  }

  // Get team members for a lead
  @Get('team/my-members')
  @UseGuards(AuthGuard('jwt'))
  getMyTeamMembers(@Request() req: { user: any }) {
    return this.companyService.getTeamMembers(req.user.id);
  }

  // Get all leads in company
  @Get(':id/leads')
  @UseGuards(AuthGuard('jwt'))
  getCompanyLeads(@Param('id') id: string) {
    return this.companyService.getCompanyLeads(id);
  }

  // Get company hierarchy
  @Get(':id/hierarchy')
  @UseGuards(AuthGuard('jwt'))
  getCompanyHierarchy(@Param('id') id: string) {
    return this.companyService.getCompanyHierarchy(id);
  }

  // Assign member to lead
  @Patch('assign-lead')
  @UseGuards(AuthGuard('jwt'))
  assignMemberToLead(
    @Body('memberId') memberId: string,
    @Body('leadId') leadId: string,
    @Request() req: { user: any },
  ) {
    return this.companyService.assignMemberToLead(memberId, leadId, req.user.id);
  }

  // Unassign member from lead
  @Patch('unassign-lead/:memberId')
  @UseGuards(AuthGuard('jwt'))
  unassignMemberFromLead(
    @Param('memberId') memberId: string,
    @Request() req: { user: any },
  ) {
    return this.companyService.unassignMemberFromLead(memberId, req.user.id);
  }
}


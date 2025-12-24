import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  UseGuards,
  Request,
  Put,
} from '@nestjs/common';
import { CompanyService } from './company.service';
import { CreateCompanyDto } from './dto/create-company.dto';
import { JoinCompanyDto } from './dto/join-company.dto';
import { AssignManagerDto } from './dto/assign-manager.dto';
import { UpdateUserTypeDto } from './dto/update-user-type.dto';
import { JwtAuthGuard } from '../auth/strategies/jwt-auth.guard';

@Controller('company')
@UseGuards(JwtAuthGuard)
export class CompanyController {
  constructor(private readonly companyService: CompanyService) {}

  @Post()
  create(@Body() createCompanyDto: CreateCompanyDto, @Request() req) {
    return this.companyService.create(createCompanyDto, req.user.userId);
  }

  @Get()
  findAll() {
    return this.companyService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.companyService.findOne(id);
  }

  @Post('join')
  joinCompany(@Body() joinCompanyDto: JoinCompanyDto, @Request() req) {
    return this.companyService.joinCompany(joinCompanyDto, req.user.userId);
  }

  @Get(':id/join-requests')
  getPendingJoinRequests(@Param('id') id: string, @Request() req) {
    return this.companyService.getPendingJoinRequests(id, req.user.userId);
  }

  @Put('join-requests/:userId/approve')
  approveJoinRequest(@Param('userId') userId: string, @Request() req) {
    return this.companyService.approveJoinRequest(userId, req.user.userId);
  }

  @Put('join-requests/:userId/reject')
  rejectJoinRequest(@Param('userId') userId: string, @Request() req) {
    return this.companyService.rejectJoinRequest(userId, req.user.userId);
  }

  @Get(':id/members')
  getCompanyMembers(@Param('id') id: string) {
    return this.companyService.getCompanyMembers(id);
  }

  @Put('members/user-type')
  updateUserType(@Body() dto: UpdateUserTypeDto, @Request() req) {
    return this.companyService.updateUserType(dto, req.user.userId);
  }

  @Put('members/assign-manager')
  assignDirectManager(@Body() dto: AssignManagerDto, @Request() req) {
    return this.companyService.assignDirectManager(dto, req.user.userId);
  }

  @Delete('members/:userId')
  removeFromCompany(@Param('userId') userId: string, @Request() req) {
    return this.companyService.removeFromCompany(userId, req.user.userId);
  }

  @Get(':id/org-chart')
  getOrgChart(@Param('id') id: string) {
    return this.companyService.getOrgChart(id);
  }
}

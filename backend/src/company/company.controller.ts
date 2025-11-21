import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
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
}


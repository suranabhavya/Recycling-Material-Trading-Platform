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
import { BranchesService } from './branches.service';
import { CreateBranchDto } from './dto/create-branch.dto';
import { UpdateBranchDto } from './dto/update-branch.dto';
import { JwtAuthGuard } from '../auth/strategies/jwt-auth.guard';

@Controller('branches')
@UseGuards(JwtAuthGuard)
export class BranchesController {
  constructor(private readonly branchesService: BranchesService) {}

  @Post('company/:companyId')
  create(
    @Param('companyId') companyId: string,
    @Body() dto: CreateBranchDto,
    @Request() req,
  ) {
    return this.branchesService.create(companyId, dto, req.user.userId);
  }

  @Get('company/:companyId')
  findAll(@Param('companyId') companyId: string) {
    return this.branchesService.findAll(companyId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.branchesService.findOne(id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() dto: UpdateBranchDto, @Request() req) {
    return this.branchesService.update(id, dto, req.user.userId);
  }

  @Delete(':id')
  delete(@Param('id') id: string, @Request() req) {
    return this.branchesService.delete(id, req.user.userId);
  }

  @Put('assign/:userId/:branchId')
  assignUserToBranch(
    @Param('userId') userId: string,
    @Param('branchId') branchId: string,
    @Request() req,
  ) {
    return this.branchesService.assignUserToBranch(userId, branchId, req.user.userId);
  }
}

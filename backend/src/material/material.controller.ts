import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
  Put,
} from '@nestjs/common';
import { MaterialService } from './material.service';
import { CreateMaterialDto } from './dto/create-material.dto';
import { ApproveMaterialDto } from './dto/approve-material.dto';
import { JwtAuthGuard } from '../auth/strategies/jwt-auth.guard';

@Controller('materials')
@UseGuards(JwtAuthGuard)
export class MaterialController {
  constructor(private readonly materialService: MaterialService) {}

  @Post()
  create(@Body() createMaterialDto: CreateMaterialDto, @Request() req) {
    return this.materialService.create(createMaterialDto, req.user.userId);
  }

  @Get('company/:companyId')
  findAll(@Param('companyId') companyId: string, @Request() req) {
    return this.materialService.findAll(companyId, req.user.userId);
  }

  @Get('pending-approvals')
  getPendingApprovalsForUser(@Request() req) {
    return this.materialService.getPendingApprovalsForUser(req.user.userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.materialService.findOne(id);
  }

  @Put(':id/approve')
  approveMaterial(
    @Param('id') id: string,
    @Body() dto: ApproveMaterialDto,
    @Request() req,
  ) {
    return this.materialService.approveMaterial(id, req.user.userId, dto);
  }

  @Delete(':id')
  delete(@Param('id') id: string, @Request() req) {
    return this.materialService.delete(id, req.user.userId);
  }
}

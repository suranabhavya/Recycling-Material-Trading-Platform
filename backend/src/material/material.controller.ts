import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
} from '@nestjs/common';
import { MaterialService } from './material.service';
import { CreateMaterialDto } from './dto/create-material.dto';
import { UpdateMaterialDto } from './dto/update-material.dto';
import { JwtAuthGuard } from '../auth/strategies/jwt-auth.guard';

@Controller('materials')
@UseGuards(JwtAuthGuard)
export class MaterialController {
  constructor(private readonly materialService: MaterialService) {}

  @Post()
  create(@Request() req, @Body() createMaterialDto: CreateMaterialDto) {
    return this.materialService.create(req.user.id, createMaterialDto);
  }

  @Get()
  findAll(@Request() req) {
    return this.materialService.findAll(req.user.id);
  }

  // Lead endpoints - must come before :id route
  @Get('pending-lead-approval')
  getPendingLeadApproval(@Request() req: { user: any }) {
    return this.materialService.getPendingLeadApproval(req.user.id);
  }

  @Get('approved-for-batching')
  getApprovedMaterials(@Request() req: { user: any }) {
    return this.materialService.getApprovedMaterials(req.user.id);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    return this.materialService.findOne(id, req.user.id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Request() req,
    @Body() updateMaterialDto: UpdateMaterialDto,
  ) {
    return this.materialService.update(id, req.user.id, updateMaterialDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.materialService.remove(id, req.user.id);
  }

  @Patch(':id/status')
  updateStatus(
    @Param('id') id: string,
    @Request() req,
    @Body() body: { status: 'APPROVED_BY_ADMIN' | 'REJECTED_BY_ADMIN' },
  ) {
    return this.materialService.updateStatus(id, req.user.id, body.status);
  }

  @Patch(':id/lead-approve')
  leadApproveMaterial(@Param('id') id: string, @Request() req: { user: any }) {
    return this.materialService.leadApproveMaterial(id, req.user.id);
  }

  @Patch(':id/lead-reject')
  leadRejectMaterial(@Param('id') id: string, @Request() req: { user: any }) {
    return this.materialService.leadRejectMaterial(id, req.user.id);
  }
}


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
import { MaterialApprovalService } from './material-approval.service';
import { CreateMaterialDto } from './dto/create-material.dto';
import { UpdateMaterialDto } from './dto/update-material.dto';
import { JwtAuthGuard } from '../auth/strategies/jwt-auth.guard';

@Controller('materials')
@UseGuards(JwtAuthGuard)
export class MaterialController {
  constructor(
    private readonly materialService: MaterialService,
    private readonly approvalService: MaterialApprovalService,
  ) {}

  @Post()
  create(@Request() req, @Body() createMaterialDto: CreateMaterialDto) {
    return this.materialService.create(req.user.id, createMaterialDto);
  }

  @Get()
  findAll(@Request() req) {
    return this.materialService.findAll(req.user.id);
  }

  @Get('my-materials')
  getMyMaterials(@Request() req) {
    return this.materialService.findMyMaterials(req.user.id);
  }

  @Get('pending-approvals')
  getPendingApprovals(@Request() req) {
    return this.approvalService.getPendingApprovals(req.user.id);
  }

  @Get('inventory')
  getInventory(@Request() req) {
    return this.materialService.getInventory(req.user.id);
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

  @Post(':id/approve')
  approveMaterial(@Param('id') id: string, @Request() req) {
    return this.approvalService.approveMaterial(id, req.user.id);
  }

  @Post(':id/reject')
  rejectMaterial(
    @Param('id') id: string,
    @Request() req,
    @Body() body: { reason: string },
  ) {
    return this.approvalService.rejectMaterial(id, req.user.id, body.reason);
  }
}

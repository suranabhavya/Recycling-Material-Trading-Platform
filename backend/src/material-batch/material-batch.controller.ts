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
import { MaterialBatchService } from './material-batch.service';
import { CreateBatchDto } from './dto/create-batch.dto';
import { AddMaterialsDto } from './dto/add-materials.dto';
import { JwtAuthGuard } from '../auth/strategies/jwt-auth.guard';

@Controller('material-batches')
@UseGuards(JwtAuthGuard)
export class MaterialBatchController {
  constructor(private readonly materialBatchService: MaterialBatchService) {}

  // Lead endpoints
  @Post()
  create(@Request() req, @Body() createBatchDto: CreateBatchDto) {
    return this.materialBatchService.create(req.user.id, createBatchDto);
  }

  @Post(':id/add-materials')
  addMaterials(
    @Param('id') id: string,
    @Request() req,
    @Body() addMaterialsDto: AddMaterialsDto,
  ) {
    return this.materialBatchService.addMaterials(id, req.user.id, addMaterialsDto);
  }

  @Post(':id/remove-materials')
  removeMaterials(
    @Param('id') id: string,
    @Request() req,
    @Body() addMaterialsDto: AddMaterialsDto,
  ) {
    return this.materialBatchService.removeMaterials(id, req.user.id, addMaterialsDto);
  }

  @Post(':id/submit')
  submitBatch(@Param('id') id: string, @Request() req) {
    return this.materialBatchService.submitBatch(id, req.user.id);
  }

  @Get('my-batches')
  getMyBatches(@Request() req) {
    return this.materialBatchService.getMyBatches(req.user.id);
  }

  @Get(':id')
  getBatchDetails(@Param('id') id: string) {
    return this.materialBatchService.getBatchDetails(id);
  }

  @Delete(':id')
  deleteBatch(@Param('id') id: string, @Request() req) {
    return this.materialBatchService.deleteBatch(id, req.user.id);
  }

  // Admin endpoints
  @Get('admin/pending')
  getPendingBatches(@Request() req) {
    return this.materialBatchService.getPendingBatches(req.user.id);
  }

  @Patch(':id/approve')
  approveBatch(@Param('id') id: string, @Request() req) {
    return this.materialBatchService.approveBatch(id, req.user.id);
  }

  @Patch(':id/reject')
  rejectBatch(@Param('id') id: string, @Request() req) {
    return this.materialBatchService.rejectBatch(id, req.user.id);
  }

  @Get('admin/all')
  getAllBatches(@Request() req) {
    return this.materialBatchService.getAllBatches(req.user.id);
  }
}


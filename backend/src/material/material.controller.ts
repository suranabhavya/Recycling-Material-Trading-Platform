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
    @Body() body: { status: 'APPROVED' | 'REJECTED' },
  ) {
    return this.materialService.updateStatus(id, req.user.id, body.status);
  }
}


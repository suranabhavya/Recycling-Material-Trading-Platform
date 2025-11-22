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
import { BatchService } from './batch.service';
import { CreateBatchDto } from './dto/create-batch.dto';
import { UpdateBatchDto } from './dto/update-batch.dto';
import { JwtAuthGuard } from '../auth/strategies/jwt-auth.guard';

@Controller('batches')
@UseGuards(JwtAuthGuard)
export class BatchController {
  constructor(private readonly batchService: BatchService) {}

  @Post()
  create(@Body() createBatchDto: CreateBatchDto, @Request() req: { user: any }) {
    return this.batchService.create(req.user.id, createBatchDto);
  }

  @Get()
  findAll(@Request() req: { user: any }) {
    return this.batchService.findAll(req.user.id);
  }

  @Get('pending-admin-approval')
  getPendingBatches(@Request() req: { user: any }) {
    return this.batchService.getPendingBatches(req.user.id);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req: { user: any }) {
    return this.batchService.findOne(id, req.user.id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateBatchDto: UpdateBatchDto,
    @Request() req: { user: any },
  ) {
    return this.batchService.update(id, req.user.id, updateBatchDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req: { user: any }) {
    return this.batchService.remove(id, req.user.id);
  }

  @Post(':id/submit')
  submitBatch(@Param('id') id: string, @Request() req: { user: any }) {
    return this.batchService.submitBatch(id, req.user.id);
  }

  @Post(':id/approve')
  approveBatch(@Param('id') id: string, @Request() req: { user: any }) {
    return this.batchService.approveBatch(id, req.user.id);
  }

  @Post(':id/reject')
  rejectBatch(@Param('id') id: string, @Request() req: { user: any }) {
    return this.batchService.rejectBatch(id, req.user.id);
  }
}


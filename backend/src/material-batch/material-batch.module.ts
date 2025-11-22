import { Module } from '@nestjs/common';
import { MaterialBatchService } from './material-batch.service';
import { MaterialBatchController } from './material-batch.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [MaterialBatchController],
  providers: [MaterialBatchService],
})
export class MaterialBatchModule {}


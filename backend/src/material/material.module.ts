import { Module } from '@nestjs/common';
import { MaterialService } from './material.service';
import { MaterialController } from './material.controller';
import { MaterialApprovalService } from './material-approval.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [MaterialController],
  providers: [MaterialService, MaterialApprovalService],
  exports: [MaterialService, MaterialApprovalService],
})
export class MaterialModule {}


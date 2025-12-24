import { Module } from '@nestjs/common';
import { SmartGroupsService } from './smart-groups.service';
import { SmartGroupsController } from './smart-groups.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [SmartGroupsController],
  providers: [SmartGroupsService],
  exports: [SmartGroupsService],
})
export class SmartGroupsModule {}

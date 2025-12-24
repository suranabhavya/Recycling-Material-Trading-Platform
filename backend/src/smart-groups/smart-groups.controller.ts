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
import { SmartGroupsService } from './smart-groups.service';
import { CreateSmartGroupDto } from './dto/create-smart-group.dto';
import { AddMemberDto } from './dto/add-member.dto';
import { JwtAuthGuard } from '../auth/strategies/jwt-auth.guard';

@Controller('smart-groups')
@UseGuards(JwtAuthGuard)
export class SmartGroupsController {
  constructor(private readonly smartGroupsService: SmartGroupsService) {}

  @Post('company/:companyId')
  create(
    @Param('companyId') companyId: string,
    @Body() dto: CreateSmartGroupDto,
    @Request() req,
  ) {
    return this.smartGroupsService.create(companyId, dto, req.user.userId);
  }

  @Get('company/:companyId')
  findAll(@Param('companyId') companyId: string) {
    return this.smartGroupsService.findAll(companyId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.smartGroupsService.findOne(id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() dto: CreateSmartGroupDto, @Request() req) {
    return this.smartGroupsService.update(id, dto, req.user.userId);
  }

  @Delete(':id')
  delete(@Param('id') id: string, @Request() req) {
    return this.smartGroupsService.delete(id, req.user.userId);
  }

  @Post(':id/members')
  addMember(@Param('id') id: string, @Body() dto: AddMemberDto, @Request() req) {
    return this.smartGroupsService.addMember(id, dto, req.user.userId);
  }

  @Delete(':id/members/:userId')
  removeMember(@Param('id') id: string, @Param('userId') userId: string, @Request() req) {
    return this.smartGroupsService.removeMember(id, userId, req.user.userId);
  }
}

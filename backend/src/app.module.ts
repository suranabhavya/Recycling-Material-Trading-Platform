import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { CompanyModule } from './company/company.module';
import { CloudinaryModule } from './cloudinary/cloudinary.module';
import { UploadModule } from './upload/upload.module';
import { MaterialModule } from './material/material.module';
import { PermissionsModule } from './permissions/permissions.module';
import { SmartGroupsModule } from './smart-groups/smart-groups.module';
import { RolesModule } from './roles/roles.module';
import { BranchesModule } from './branches/branches.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    CompanyModule,
    CloudinaryModule,
    UploadModule,
    MaterialModule,
    PermissionsModule,
    SmartGroupsModule,
    RolesModule,
    BranchesModule,
    UsersModule,
  ],
})
export class AppModule {}

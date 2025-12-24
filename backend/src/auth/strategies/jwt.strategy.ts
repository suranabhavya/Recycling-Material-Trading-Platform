import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: process.env.JWT_SECRET || 'your-secret-key',
    });
  }

  async validate(payload: any) {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      include: {
        company: true,
        role: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException();
    }

    // Map userType to roleTemplate for compatibility with Flutter app
    const roleTemplate = {
      isAdmin: user.userType === 'OWNER' || user.userType === 'ADMIN',
      name: user.userType,
    };

    return {
      userId: user.id,
      email: user.email,
      user: {
        ...user,
        roleTemplate,
        companyApprovalStatus: user.joinRequestStatus,
      },
    };
  }
}

import { Injectable, UnauthorizedException, ConflictException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { EmailService } from '../email/email.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { SendOtpDto, VerifyOtpDto, ResetPasswordDto } from './dto/verify-otp.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private emailService: EmailService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (existing) {
      throw new ConflictException('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);

    // Use transaction to ensure user is only created if OTP is sent successfully
    try {
      const user = await this.prisma.user.create({
        data: {
          email: dto.email,
          password: hashedPassword,
          name: dto.name,
          isVerified: false,
        },
      });

      // Try to send OTP - if this fails, the user creation will be rolled back
      await this.sendOtp({ email: dto.email }, 'verification');

      return {
        message: 'Registration successful. Please verify your email with the OTP sent.',
        email: user.email,
      };
    } catch (error) {
      // If OTP sending fails, delete the user that was just created
      await this.prisma.user.deleteMany({
        where: { email: dto.email, isVerified: false },
      });
      throw error;
    }
  }

  async sendOtp(dto: SendOtpDto, type: string = 'verification') {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Get user for name
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    await this.prisma.otp.deleteMany({
      where: { email: dto.email, type },
    });

    await this.prisma.otp.create({
      data: {
        email: dto.email,
        otp,
        type,
        expiresAt,
      },
    });

    // Send email based on type
    if (type === 'verification') {
      await this.emailService.sendVerificationOtp(dto.email, otp, user.name);
    } else if (type === 'reset_password') {
      await this.emailService.sendPasswordResetOtp(dto.email, otp, user.name);
    }

    return { message: 'OTP sent successfully' };
  }

  async verifyOtp(dto: VerifyOtpDto) {
    const otpRecord = await this.prisma.otp.findFirst({
      where: {
        email: dto.email,
        otp: dto.otp,
        type: 'verification',
        expiresAt: { gte: new Date() },
      },
    });

    if (!otpRecord) {
      throw new BadRequestException('Invalid or expired OTP');
    }

    await this.prisma.user.update({
      where: { email: dto.email },
      data: { isVerified: true },
    });

    await this.prisma.otp.delete({
      where: { id: otpRecord.id },
    });

    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
      include: { company: true },
    });

    const token = this.generateToken(user!.id);

    return {
      user: {
        id: user!.id,
        email: user!.email,
        name: user!.name,
        isVerified: user!.isVerified,
        companyId: user!.companyId,
        companyApprovalStatus: user!.companyApprovalStatus,
        company: user!.company,
      },
      token,
    };
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
      include: { company: true },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.isVerified) {
      throw new UnauthorizedException('Please verify your email first');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.password);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const token = this.generateToken(user.id);

    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        isVerified: user.isVerified,
        companyId: user.companyId,
        companyApprovalStatus: user.companyApprovalStatus,
        company: user.company,
      },
      token,
    };
  }

  async forgotPassword(dto: SendOtpDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (!user) {
      return { message: 'If email exists, OTP has been sent' };
    }

    await this.sendOtp(dto, 'reset_password');
    return { message: 'OTP sent to your email' };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const otpRecord = await this.prisma.otp.findFirst({
      where: {
        email: dto.email,
        otp: dto.otp,
        type: 'reset_password',
        expiresAt: { gte: new Date() },
      },
    });

    if (!otpRecord) {
      throw new BadRequestException('Invalid or expired OTP');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);

    await this.prisma.user.update({
      where: { email: dto.email },
      data: { password: hashedPassword },
    });

    await this.prisma.otp.delete({
      where: { id: otpRecord.id },
    });

    return { message: 'Password reset successful' };
  }

  private generateToken(userId: string) {
    return this.jwtService.sign({ sub: userId });
  }
}

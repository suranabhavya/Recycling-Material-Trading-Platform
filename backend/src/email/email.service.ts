import { Injectable, Logger } from '@nestjs/common';
import sgMail from '@sendgrid/mail';

@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);

  constructor() {
    const apiKey = process.env.SENDGRID_API_KEY;
    if (apiKey) {
      sgMail.setApiKey(apiKey);
    } else {
      this.logger.warn('SendGrid API key not configured. Emails will be logged to console.');
    }
  }

  async sendVerificationOtp(email: string, otp: string, name: string): Promise<void> {
    const msg = {
      to: email,
      from: process.env.SENDGRID_FROM_EMAIL || 'noreply@gravita.com',
      subject: 'Verify Your Email - Gravita Recycling Platform',
      text: `Hello ${name},\n\nYour OTP for email verification is: ${otp}\n\nThis OTP will expire in 10 minutes.\n\nIf you didn't request this, please ignore this email.\n\nBest regards,\nGravita Recycling Platform`,
      html: this.getVerificationEmailTemplate(name, otp),
    };

    await this.sendEmail(msg);
  }

  async sendPasswordResetOtp(email: string, otp: string, name: string): Promise<void> {
    const msg = {
      to: email,
      from: process.env.SENDGRID_FROM_EMAIL || 'noreply@gravita.com',
      subject: 'Reset Your Password - Gravita Recycling Platform',
      text: `Hello ${name},\n\nYour OTP for password reset is: ${otp}\n\nThis OTP will expire in 10 minutes.\n\nIf you didn't request this, please ignore this email and your password will remain unchanged.\n\nBest regards,\nGravita Recycling Platform`,
      html: this.getPasswordResetEmailTemplate(name, otp),
    };

    await this.sendEmail(msg);
  }

  private async sendEmail(msg: sgMail.MailDataRequired): Promise<void> {
    try {
      if (process.env.SENDGRID_API_KEY) {
        await sgMail.send(msg);
        this.logger.log(`Email sent successfully to ${msg.to}`);
      } else {
        // Development mode: log email to console
        this.logger.log('=== EMAIL (Development Mode) ===');
        this.logger.log(`To: ${msg.to}`);
        this.logger.log(`From: ${msg.from}`);
        this.logger.log(`Subject: ${msg.subject}`);
        this.logger.log(`Text: ${msg.text}`);
        this.logger.log('================================');
      }
    } catch (error) {
      this.logger.error('Error sending email:', error);
      throw new Error('Failed to send email');
    }
  }

  private getVerificationEmailTemplate(name: string, otp: string): string {
    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verify Your Email</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      line-height: 1.6;
      color: #333;
      background-color: #f4f4f4;
      margin: 0;
      padding: 0;
    }
    .container {
      max-width: 600px;
      margin: 30px auto;
      background: #ffffff;
      border-radius: 10px;
      overflow: hidden;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .header {
      background: linear-gradient(135deg, #1B5E20 0%, #2E7D32 100%);
      color: white;
      padding: 40px 20px;
      text-align: center;
    }
    .header h1 {
      margin: 0;
      font-size: 28px;
      font-weight: 600;
    }
    .content {
      padding: 40px 30px;
    }
    .otp-box {
      background: linear-gradient(135deg, #E8F5E9 0%, #C8E6C9 100%);
      border: 2px dashed #2E7D32;
      border-radius: 10px;
      padding: 30px;
      text-align: center;
      margin: 30px 0;
    }
    .otp-code {
      font-size: 42px;
      font-weight: bold;
      color: #1B5E20;
      letter-spacing: 8px;
      margin: 10px 0;
    }
    .footer {
      background: #f9f9f9;
      padding: 20px 30px;
      text-align: center;
      font-size: 14px;
      color: #666;
      border-top: 1px solid #e0e0e0;
    }
    .btn {
      display: inline-block;
      padding: 12px 30px;
      background: linear-gradient(135deg, #1B5E20 0%, #2E7D32 100%);
      color: white;
      text-decoration: none;
      border-radius: 5px;
      margin: 20px 0;
      font-weight: 600;
    }
    .warning {
      background: #FFF3E0;
      border-left: 4px solid #FF9800;
      padding: 15px;
      margin: 20px 0;
      border-radius: 5px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🌱 Gravita Recycling Platform</h1>
    </div>
    <div class="content">
      <h2>Hello ${name}!</h2>
      <p>Thank you for registering with Gravita Recycling Platform. To complete your registration, please verify your email address using the OTP below:</p>
      
      <div class="otp-box">
        <p style="margin: 0; font-size: 14px; color: #666;">Your Verification Code</p>
        <div class="otp-code">${otp}</div>
        <p style="margin: 10px 0 0 0; font-size: 12px; color: #666;">Valid for 10 minutes</p>
      </div>

      <div class="warning">
        <strong>⚠️ Security Notice:</strong> Never share this OTP with anyone. Gravita will never ask for your OTP via phone or email.
      </div>

      <p>If you didn't create an account with Gravita, please ignore this email.</p>
    </div>
    <div class="footer">
      <p>© ${new Date().getFullYear()} Gravita India. All rights reserved.</p>
      <p>This is an automated email. Please do not reply.</p>
    </div>
  </div>
</body>
</html>
    `;
  }

  private getPasswordResetEmailTemplate(name: string, otp: string): string {
    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Your Password</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      line-height: 1.6;
      color: #333;
      background-color: #f4f4f4;
      margin: 0;
      padding: 0;
    }
    .container {
      max-width: 600px;
      margin: 30px auto;
      background: #ffffff;
      border-radius: 10px;
      overflow: hidden;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .header {
      background: linear-gradient(135deg, #C62828 0%, #E53935 100%);
      color: white;
      padding: 40px 20px;
      text-align: center;
    }
    .header h1 {
      margin: 0;
      font-size: 28px;
      font-weight: 600;
    }
    .content {
      padding: 40px 30px;
    }
    .otp-box {
      background: linear-gradient(135deg, #FFEBEE 0%, #FFCDD2 100%);
      border: 2px dashed #E53935;
      border-radius: 10px;
      padding: 30px;
      text-align: center;
      margin: 30px 0;
    }
    .otp-code {
      font-size: 42px;
      font-weight: bold;
      color: #C62828;
      letter-spacing: 8px;
      margin: 10px 0;
    }
    .footer {
      background: #f9f9f9;
      padding: 20px 30px;
      text-align: center;
      font-size: 14px;
      color: #666;
      border-top: 1px solid #e0e0e0;
    }
    .warning {
      background: #FFF3E0;
      border-left: 4px solid #FF9800;
      padding: 15px;
      margin: 20px 0;
      border-radius: 5px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🔐 Password Reset Request</h1>
    </div>
    <div class="content">
      <h2>Hello ${name}!</h2>
      <p>We received a request to reset your password for your Gravita Recycling Platform account. Use the OTP below to proceed:</p>
      
      <div class="otp-box">
        <p style="margin: 0; font-size: 14px; color: #666;">Your Password Reset Code</p>
        <div class="otp-code">${otp}</div>
        <p style="margin: 10px 0 0 0; font-size: 12px; color: #666;">Valid for 10 minutes</p>
      </div>

      <div class="warning">
        <strong>⚠️ Security Notice:</strong> If you didn't request a password reset, please ignore this email. Your password will remain unchanged.
      </div>

      <p>For security reasons, this OTP will expire in 10 minutes.</p>
    </div>
    <div class="footer">
      <p>© ${new Date().getFullYear()} Gravita India. All rights reserved.</p>
      <p>This is an automated email. Please do not reply.</p>
    </div>
  </div>
</body>
</html>
    `;
  }
}


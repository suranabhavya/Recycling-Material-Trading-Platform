# Gravita Recycling Platform

Modern Business to Business waste material trading platform with beautiful UI/UX and email OTP verification.

## Tech Stack

**Frontend:** Flutter + Riverpod + Go Router + Glassmorphism  
**Backend:** NestJS + Prisma + PostgreSQL + SendGrid  
**Auth:** JWT tokens + Email OTP verification  

## Quick Start

### 1. Backend Setup

```bash
cd backend
npm install

# Set up database
npx prisma migrate dev
npx prisma generate

# Configure SendGrid (optional for dev)
# See SENDGRID_SETUP.md for detailed instructions
# For development, emails will be logged to console

# Start backend
npm run start:dev
```

### 2. Frontend Setup

```bash
cd frontend
flutter pub get
flutter run
```

### 3. Email Configuration (Optional)

For development, OTPs are logged to the backend console. For production:

1. See `backend/SENDGRID_SETUP.md` for detailed SendGrid setup
2. Add your SendGrid API key to `backend/.env`:
   ```env
   SENDGRID_API_KEY="your_api_key_here"
   SENDGRID_FROM_EMAIL="your-verified-email@example.com"
   ```

## Features

✅ User registration with email verification  
✅ Email OTP verification (6-digit code, 10-min expiry)  
✅ Login with JWT authentication  
✅ Forgot password with email OTP  
✅ Beautiful glassmorphic UI with animations  
✅ Responsive design  

## Development Mode

When `SENDGRID_API_KEY` is not set in `.env`, the system automatically:
- Logs OTPs to the backend console
- Shows email content in terminal
- Perfect for local development without email setup!

## Authentication Flow

### Registration
1. User registers with name, email, password
2. OTP sent to email (or logged to console in dev mode)
3. User verifies email with OTP
4. Account activated

### Login
1. User logs in with email and password
2. JWT token issued
3. Token stored securely in Flutter app

### Password Reset
1. User requests password reset
2. OTP sent to email
3. User enters OTP and new password
4. Password updated

## Test Credentials

For development testing, you can create a verified user directly in the database:

```bash
cd backend
npx prisma studio
```

Or use the registration flow with console OTP logging.

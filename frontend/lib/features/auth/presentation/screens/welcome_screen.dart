import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/router/app_router.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // Illustration
              _buildIllustration(),

              const SizedBox(height: 60),

              // Welcome text
              Text(
                'Welcome to Gravita',
                style: GoogleFonts.domine(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Login to join your team or create a new\ncompany app within seconds',
                style: GoogleFonts.domine(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRouter.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.domine(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Create new company button
              TextButton(
                onPressed: () => context.go(AppRouter.registerCompany),
                child: Text(
                  'Create new company',
                  style: GoogleFonts.domine(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Terms and Privacy
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.domine(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'By signing up you agree to our '),
                    TextSpan(
                      text: 'Terms of use',
                      style: GoogleFonts.domine(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' and confirm\nyou have read our '),
                    TextSpan(
                      text: 'Privacy policy',
                      style: GoogleFonts.domine(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Version number
              Text(
                '1.0.0',
                style: GoogleFonts.domine(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circles
          Positioned(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
          ),

          // Main circle with gradient
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.7),
                  AppColors.primary.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile icon placeholder
                    Container(
                      width: 40,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Icon grid
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildIconBox(Colors.blue.shade300),
                        const SizedBox(width: 8),
                        _buildIconBox(Colors.orange.shade300),
                        const SizedBox(width: 8),
                        _buildIconBox(Colors.teal.shade300),
                        const SizedBox(width: 8),
                        _buildIconBox(Colors.pink.shade300),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Card placeholder
                    Container(
                      width: 120,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade200, Colors.purple.shade300],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 60,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating icons around the circle
          Positioned(
            top: 20,
            left: 100,
            child: _buildFloatingIcon(Icons.person, Colors.pink.shade300),
          ),
          Positioned(
            top: 80,
            left: 20,
            child: _buildFloatingIcon(Icons.recycling, Colors.teal.shade300),
          ),
          Positioned(
            bottom: 20,
            right: 100,
            child: _buildFloatingIcon(Icons.timer, Colors.blue.shade300),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: _buildFloatingIcon(Icons.calendar_today, Colors.orange.shade300),
          ),
          Positioned(
            top: 100,
            right: 40,
            child: _buildFloatingDot(Colors.pink.shade200),
          ),
          Positioned(
            bottom: 100,
            left: 40,
            child: _buildFloatingDot(Colors.blue.shade200),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildFloatingDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

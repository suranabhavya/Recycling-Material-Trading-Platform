import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Help & Support',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions
                      Text(
                        'Quick Actions',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              icon: Icons.email_outlined,
                              title: 'Email Us',
                              subtitle: 'support@recycling.com',
                              color: AppColors.primary,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Opening email client...'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              icon: Icons.phone_outlined,
                              title: 'Call Us',
                              subtitle: '+91 1234567890',
                              color: AppColors.success,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Opening phone dialer...'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                      
                      const SizedBox(height: 30),
                      
                      // FAQs
                      Text(
                        'Frequently Asked Questions',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                      
                      const SizedBox(height: 16),
                      
                      _buildFAQItem(
                        question: 'How do I register my company?',
                        answer: 'Navigate to the company selection screen after login and tap on "Register New Company". Fill in the required details and submit for approval.',
                      ).animate().fadeIn(duration: 600.ms, delay: 250.ms),
                      
                      const SizedBox(height: 12),
                      
                      _buildFAQItem(
                        question: 'How long does company approval take?',
                        answer: 'Company approval typically takes 1-2 business days. You\'ll receive an email notification once your company is approved.',
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                      
                      const SizedBox(height: 12),
                      
                      _buildFAQItem(
                        question: 'How do I add scrap materials?',
                        answer: 'Once your company is approved, navigate to the "Add Scrap" tab from the bottom navigation. Fill in the material details and submit for listing.',
                      ).animate().fadeIn(duration: 600.ms, delay: 350.ms),
                      
                      const SizedBox(height: 12),
                      
                      _buildFAQItem(
                        question: 'Can I invite team members?',
                        answer: 'Yes, if you\'re a company admin, you can invite team members from the Team Management section in your profile settings.',
                      ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                      
                      const SizedBox(height: 12),
                      
                      _buildFAQItem(
                        question: 'How do I change my password?',
                        answer: 'Go to Profile > Personal Settings and click on "Change Password". You\'ll need to enter your current password and choose a new one.',
                      ).animate().fadeIn(duration: 600.ms, delay: 450.ms),
                      
                      const SizedBox(height: 30),
                      
                      // Help Resources
                      Text(
                        'Help Resources',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                      
                      const SizedBox(height: 16),
                      
                      _buildResourceTile(
                        context,
                        icon: Icons.book_outlined,
                        title: 'User Guide',
                        subtitle: 'Complete guide to using the platform',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User guide coming soon!'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        },
                      ).animate().fadeIn(duration: 600.ms, delay: 550.ms),
                      
                      const SizedBox(height: 12),
                      
                      _buildResourceTile(
                        context,
                        icon: Icons.video_library_outlined,
                        title: 'Video Tutorials',
                        subtitle: 'Watch step-by-step tutorials',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Video tutorials coming soon!'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        },
                      ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                      
                      const SizedBox(height: 12),
                      
                      _buildResourceTile(
                        context,
                        icon: Icons.article_outlined,
                        title: 'Terms of Service',
                        subtitle: 'Read our terms and conditions',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Terms of service coming soon!'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        },
                      ).animate().fadeIn(duration: 600.ms, delay: 650.ms),
                      
                      const SizedBox(height: 12),
                      
                      _buildResourceTile(
                        context,
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Learn how we protect your data',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Privacy policy coming soon!'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        },
                      ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
                      
                      const SizedBox(height: 30),
                      
                      // App Info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacityValue(0.2),
                              Colors.white.withOpacityValue(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacityValue(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.recycling,
                              size: 48,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Recycling Material Platform',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Version 1.0.0',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacityValue(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '© 2025 Recycling Platform. All rights reserved.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacityValue(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 750.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacityValue(0.2),
              Colors.white.withOpacityValue(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacityValue(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacityValue(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacityValue(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacityValue(0.2),
            Colors.white.withOpacityValue(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacityValue(0.3),
          width: 1.5,
        ),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            iconColor: Colors.white,
            collapsedIconColor: Colors.white.withOpacityValue(0.8),
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          children: [
            Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacityValue(0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacityValue(0.2),
              Colors.white.withOpacityValue(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacityValue(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacityValue(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacityValue(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _profileVisibility = true;
  bool _showEmail = false;
  bool _showPhone = false;
  bool _twoFactorAuth = false;
  bool _dataCollection = true;

  @override
  Widget build(BuildContext context) {
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
                      'Privacy & Security',
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
                      // Privacy Settings
                      Text(
                        'Privacy',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                      
                      const SizedBox(height: 16),
                      
                      Container(
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
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacityValue(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              _buildSwitchTile(
                                icon: Icons.visibility_outlined,
                                title: 'Profile Visibility',
                                subtitle: 'Make your profile visible to others',
                                value: _profileVisibility,
                                onChanged: (value) => setState(() => _profileVisibility = value),
                              ),
                              Divider(color: Colors.white.withOpacityValue(0.2)),
                              _buildSwitchTile(
                                icon: Icons.email_outlined,
                                title: 'Show Email',
                                subtitle: 'Display email on your public profile',
                                value: _showEmail,
                                onChanged: (value) => setState(() => _showEmail = value),
                              ),
                              Divider(color: Colors.white.withOpacityValue(0.2)),
                              _buildSwitchTile(
                                icon: Icons.phone_outlined,
                                title: 'Show Phone',
                                subtitle: 'Display phone number on profile',
                                value: _showPhone,
                                onChanged: (value) => setState(() => _showPhone = value),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 30),
                      
                      // Security Settings
                      Text(
                        'Security',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                      
                      const SizedBox(height: 16),
                      
                      Container(
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
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacityValue(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              _buildSwitchTile(
                                icon: Icons.security_outlined,
                                title: 'Two-Factor Authentication',
                                subtitle: 'Add extra security to your account',
                                value: _twoFactorAuth,
                                onChanged: (value) {
                                  setState(() => _twoFactorAuth = value);
                                  if (value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('2FA setup coming soon!'),
                                        backgroundColor: AppColors.warning,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 30),
                      
                      // Data & Storage
                      Text(
                        'Data & Storage',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                      
                      const SizedBox(height: 16),
                      
                      Container(
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
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacityValue(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              _buildSwitchTile(
                                icon: Icons.analytics_outlined,
                                title: 'Data Collection',
                                subtitle: 'Help improve our service with usage data',
                                value: _dataCollection,
                                onChanged: (value) => setState(() => _dataCollection = value),
                              ),
                              Divider(color: Colors.white.withOpacityValue(0.2)),
                              _buildActionTile(
                                icon: Icons.download_outlined,
                                title: 'Download Your Data',
                                subtitle: 'Get a copy of your data',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Data export coming soon!'),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                },
                              ),
                              Divider(color: Colors.white.withOpacityValue(0.2)),
                              _buildActionTile(
                                icon: Icons.delete_outline,
                                title: 'Delete Account',
                                subtitle: 'Permanently delete your account',
                                color: AppColors.error,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: AppColors.darkGreen,
                                      title: Text(
                                        'Delete Account',
                                        style: GoogleFonts.poppins(color: Colors.white),
                                      ),
                                      content: Text(
                                        'This action cannot be undone. All your data will be permanently deleted.',
                                        style: GoogleFonts.poppins(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.poppins(color: Colors.white70),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Account deletion coming soon!'),
                                                backgroundColor: AppColors.warning,
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Delete',
                                            style: GoogleFonts.poppins(color: AppColors.error),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 30),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement save privacy settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Settings saved successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Save Settings',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacityValue(0.5),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacityValue(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tileColor = color ?? Colors.white;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tileColor.withOpacityValue(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: tileColor, size: 24),
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
                      color: tileColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: tileColor.withOpacityValue(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: tileColor, size: 16),
          ],
        ),
      ),
    );
  }
}


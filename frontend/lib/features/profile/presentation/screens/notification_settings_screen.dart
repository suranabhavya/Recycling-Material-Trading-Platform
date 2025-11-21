import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _scrapUpdates = true;
  bool _teamActivity = true;
  bool _companyUpdates = true;
  bool _systemAlerts = true;
  bool _marketingEmails = false;

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
                      'Notification Settings',
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
                      // General Notifications
                      Text(
                        'General',
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
                                icon: Icons.notifications_active_outlined,
                                title: 'Push Notifications',
                                subtitle: 'Receive push notifications on this device',
                                value: _pushNotifications,
                                onChanged: (value) => setState(() => _pushNotifications = value),
                              ),
                              Divider(color: Colors.white.withOpacityValue(0.2)),
                              _buildSwitchTile(
                                icon: Icons.email_outlined,
                                title: 'Email Notifications',
                                subtitle: 'Receive notifications via email',
                                value: _emailNotifications,
                                onChanged: (value) => setState(() => _emailNotifications = value),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 30),
                      
                      // Activity Notifications
                      Text(
                        'Activity',
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
                                icon: Icons.inventory_2_outlined,
                                title: 'Scrap Updates',
                                subtitle: 'Notifications about your scrap listings',
                                value: _scrapUpdates,
                                onChanged: (value) => setState(() => _scrapUpdates = value),
                              ),
                              Divider(color: Colors.white.withOpacityValue(0.2)),
                              _buildSwitchTile(
                                icon: Icons.group_outlined,
                                title: 'Team Activity',
                                subtitle: 'Updates from your team members',
                                value: _teamActivity,
                                onChanged: (value) => setState(() => _teamActivity = value),
                              ),
                              Divider(color: Colors.white.withOpacityValue(0.2)),
                              _buildSwitchTile(
                                icon: Icons.business_outlined,
                                title: 'Company Updates',
                                subtitle: 'Important company announcements',
                                value: _companyUpdates,
                                onChanged: (value) => setState(() => _companyUpdates = value),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 30),
                      
                      // System Notifications
                      Text(
                        'System',
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
                                icon: Icons.warning_amber_outlined,
                                title: 'System Alerts',
                                subtitle: 'Important system notifications',
                                value: _systemAlerts,
                                onChanged: (value) => setState(() => _systemAlerts = value),
                              ),
                              Divider(color: Colors.white.withOpacityValue(0.2)),
                              _buildSwitchTile(
                                icon: Icons.campaign_outlined,
                                title: 'Marketing Emails',
                                subtitle: 'Promotional offers and updates',
                                value: _marketingEmails,
                                onChanged: (value) => setState(() => _marketingEmails = value),
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
                            // TODO: Implement save notification settings
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
                            'Save Preferences',
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
}


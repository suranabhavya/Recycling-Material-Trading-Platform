import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final company = user?.company;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Information Section
            _buildSectionHeader('Company Information'),
            const SizedBox(height: 12),
            _buildInfoCard(
              children: [
                _buildInfoRow(
                  icon: Icons.business,
                  label: 'Company Name',
                  value: company?.name ?? 'N/A',
                  trailing: isAdmin
                      ? IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          color: AppColors.primary,
                          onPressed: () {
                            // TODO: Edit company name
                          },
                        )
                      : null,
                ),
                const Divider(height: 24, color: AppColors.divider),
                _buildInfoRow(
                  icon: Icons.category,
                  label: 'Company Type',
                  value: company?.type ?? 'N/A',
                  trailing: isAdmin
                      ? IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          color: AppColors.primary,
                          onPressed: () {
                            // TODO: Edit company type
                          },
                        )
                      : null,
                ),
                const Divider(height: 24, color: AppColors.divider),
                _buildInfoRow(
                  icon: Icons.fingerprint,
                  label: 'Company ID',
                  value: company?.id ?? 'N/A',
                  valueStyle: GoogleFonts.robotoMono(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Organization Settings Section (Admin only)
            if (isAdmin) ...[
              _buildSectionHeader('Organization Settings'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                children: [
                  _buildSettingTile(
                    icon: Icons.approval,
                    title: 'Material Approval Workflow',
                    subtitle: 'Configure approval process for materials',
                    onTap: () {
                      // TODO: Configure approval workflow
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildSettingTile(
                    icon: Icons.security,
                    title: 'Permissions & Access',
                    subtitle: 'Manage user permissions and roles',
                    onTap: () {
                      // TODO: Manage permissions
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildSettingTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Configure company-wide notifications',
                    onTap: () {
                      // TODO: Configure notifications
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Account Settings Section
            _buildSectionHeader('Account Settings'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              children: [
                _buildSettingTile(
                  icon: Icons.person,
                  title: 'Profile Settings',
                  subtitle: 'Update your personal information',
                  onTap: () {
                    // TODO: Navigate to profile settings
                  },
                ),
                const Divider(height: 1, color: AppColors.divider),
                _buildSettingTile(
                  icon: Icons.lock,
                  title: 'Security',
                  subtitle: 'Change password and security settings',
                  onTap: () {
                    // TODO: Navigate to security settings
                  },
                ),
                const Divider(height: 1, color: AppColors.divider),
                _buildSettingTile(
                  icon: Icons.notifications_active,
                  title: 'Personal Notifications',
                  subtitle: 'Manage your notification preferences',
                  onTap: () {
                    // TODO: Navigate to notification settings
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Danger Zone Section (Admin only)
            if (isAdmin) ...[
              _buildSectionHeader('Danger Zone'),
              const SizedBox(height: 12),
              _buildDangerCard(
                children: [
                  _buildSettingTile(
                    icon: Icons.delete_forever,
                    title: 'Delete Company',
                    subtitle: 'Permanently delete this company and all data',
                    titleColor: AppColors.error,
                    subtitleColor: AppColors.error.withValues(alpha: 0.7),
                    onTap: () {
                      // TODO: Show delete company confirmation
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // App Information
            _buildSectionHeader('About'),
            const SizedBox(height: 12),
            _buildInfoCard(
              children: [
                _buildInfoRow(
                  icon: Icons.info_outline,
                  label: 'App Version',
                  value: '1.0.0',
                ),
                const Divider(height: 24, color: AppColors.divider),
                _buildInfoRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  value: '',
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    color: AppColors.textSecondary,
                    onPressed: () {
                      // TODO: Show privacy policy
                    },
                  ),
                ),
                const Divider(height: 24, color: AppColors.divider),
                _buildInfoRow(
                  icon: Icons.description_outlined,
                  label: 'Terms of Service',
                  value: '',
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    color: AppColors.textSecondary,
                    onPressed: () {
                      // TODO: Show terms of service
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.domine(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDangerCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.domine(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (value.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  value,
                  style: valueStyle ??
                      GoogleFonts.domine(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? subtitleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: titleColor ?? AppColors.textPrimary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.domine(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.domine(
                        fontSize: 13,
                        color: subtitleColor ?? AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: titleColor ?? AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

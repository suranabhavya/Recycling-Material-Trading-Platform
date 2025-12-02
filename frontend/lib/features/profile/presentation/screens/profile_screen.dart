import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/router/app_router.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Refresh user data when profile screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
  }

  Future<void> _refreshUserData() async {
    if (_isRefreshing) return;
    
    setState(() => _isRefreshing = true);
    await ref.read(authProvider.notifier).refreshUser();
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        return AppColors.success;
      case 'PENDING':
        return AppColors.warning;
      case 'REJECTED':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getStatusEmoji(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        return '✅';
      case 'PENDING':
        return '⏳';
      case 'REJECTED':
        return '❌';
      default:
        return '❓';
    }
  }

  Color _getRoleColor(String? role) {
    switch (role?.toUpperCase()) {
      case 'ADMIN':
        return AppColors.warning;
      case 'LEAD':
        return AppColors.info;
      case 'MEMBER':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getRoleIcon(String? role) {
    switch (role?.toUpperCase()) {
      case 'ADMIN':
        return Icons.admin_panel_settings;
      case 'LEAD':
        return Icons.stars;
      case 'MEMBER':
        return Icons.person_outline;
      default:
        return Icons.person_outline;
    }
  }

  String _getRoleDisplayName(String? role) {
    if (role == null) return 'MEMBER';
    
    final upperRole = role.toUpperCase();
    switch (upperRole) {
      case 'ADMIN':
        return 'ADMIN';
      case 'LEAD':
        return 'LEAD';
      case 'MEMBER':
        return 'MEMBER';
      default:
        // If role name doesn't match known roles, return the role name as-is (capitalized)
        return role.isNotEmpty ? role.toUpperCase() : 'MEMBER';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAdmin = user?.roleTemplate?.isAdmin ?? false;
    // Use level-based check first, then fallback to name
    final userRole = isAdmin 
        ? 'ADMIN' 
        : (user?.roleTemplate?.name.toUpperCase() ?? 'MEMBER');
    final hasRoleTemplate = user?.roleTemplate != null;

    return Container(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Profile',
                    style: GoogleFonts.domine(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: _isRefreshing 
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: _isRefreshing ? null : _refreshUserData,
                  tooltip: 'Refresh profile data',
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            Text(
              'Manage your account and settings',
              style: GoogleFonts.domine(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          
            const SizedBox(height: 30),
            
            if (user != null) ...[
              // Compact Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.person, size: 32, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.domine(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: GoogleFonts.domine(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            
            if (hasRoleTemplate) const SizedBox(height: 20),
            
            // Quick Info Cards
            Row(
              children: [
                if (hasRoleTemplate) ...[
                  Expanded(
                    child: _buildInfoCard(
                      icon: _getRoleIcon(userRole),
                      label: 'Role',
                      value: _getRoleDisplayName(userRole),
                      color: _getRoleColor(userRole),
                    ),
                  ),
                  if (user.company != null) const SizedBox(width: 12),
                ],
                if (user.company != null)
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.business,
                      label: 'Company',
                      value: user.company!.name.length > 12 
                          ? '${user.company!.name.substring(0, 12)}...' 
                          : user.company!.name,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            
            if (hasRoleTemplate && user.companyApprovalStatus != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.verified_user,
                label: 'Status',
                value: user.companyApprovalStatus!.toUpperCase(),
                color: _getStatusColor(user.companyApprovalStatus),
                emoji: _getStatusEmoji(user.companyApprovalStatus),
              ),
            ],
            
            const SizedBox(height: 30),
            
            // Settings Section Title
            Text(
              'Settings',
              style: GoogleFonts.domine(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Personal Settings
            _buildSettingsButton(
              icon: Icons.person_outline,
              label: 'Personal Settings',
              subtitle: 'Edit your profile information',
              onTap: () => context.push(AppRouter.personalSettings),
            ),
            
            const SizedBox(height: 12),
            
            // Lead Dashboard (Lead Only)
            if (userRole.toUpperCase() == 'LEAD') ...[
              _buildSettingsButton(
                icon: Icons.dashboard_outlined,
                label: 'Lead Dashboard',
                subtitle: 'Approve team materials',
                onTap: () => context.push(AppRouter.leadDashboard),
                badgeText: 'LEAD',
                badgeColor: AppColors.info,
              ),
              
              const SizedBox(height: 12),
            ],
            
            // Company Settings (Admin Only)
            if (isAdmin) ...[
              _buildSettingsButton(
                icon: Icons.business_outlined,
                label: 'Company Settings',
                subtitle: 'Manage company information',
                onTap: () => context.push(AppRouter.companySettings),
                badgeText: 'ADMIN',
                badgeColor: AppColors.warning,
              ),
              
              const SizedBox(height: 12),
              
              // Pending Approvals (Admin Only)
              _buildSettingsButton(
                icon: Icons.how_to_reg_outlined,
                label: 'Pending Approvals',
                subtitle: 'Review member join requests',
                onTap: () => context.push(AppRouter.manageApprovals),
                badgeText: 'ADMIN',
                badgeColor: AppColors.warning,
              ),
              
              const SizedBox(height: 12),
              
              // Team Management (Admin Only)
              _buildSettingsButton(
                icon: Icons.group_outlined,
                label: 'Team Management',
                subtitle: 'Manage company members',
                onTap: () => context.push(AppRouter.teamManagement),
                badgeText: 'ADMIN',
                badgeColor: AppColors.warning,
              ),
              
              const SizedBox(height: 12),
              
              // Hierarchy Management (Admin Only)
              _buildSettingsButton(
                icon: Icons.account_tree_outlined,
                label: 'Team Hierarchy',
                subtitle: 'Assign members to leads',
                onTap: () => context.push(AppRouter.hierarchyManagement),
                badgeText: 'ADMIN',
                badgeColor: AppColors.warning,
              ),
              
              const SizedBox(height: 12),
              
              // Batch Approvals (Admin Only)
              _buildSettingsButton(
                icon: Icons.approval_outlined,
                label: 'Batch Approvals',
                subtitle: 'Review and approve batches',
                onTap: () => context.push(AppRouter.adminBatchApproval),
                badgeText: 'ADMIN',
                badgeColor: AppColors.warning,
              ),
              
              const SizedBox(height: 12),
            ],
            
            // Notification Settings
            _buildSettingsButton(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () => context.push(AppRouter.notificationSettings),
            ),
            
            const SizedBox(height: 12),
            
            // Privacy & Security
            _buildSettingsButton(
              icon: Icons.security_outlined,
              label: 'Privacy & Security',
              subtitle: 'Control your privacy settings',
              onTap: () => context.push(AppRouter.privacySettings),
            ),
            
            const SizedBox(height: 12),
            
            // Help & Support
            _buildSettingsButton(
              icon: Icons.help_outline,
              label: 'Help & Support',
              subtitle: 'FAQs and contact support',
              onTap: () => context.push(AppRouter.helpSupport),
            ),
            
            const SizedBox(height: 24),
            
            // Logout Button
            _buildSettingsButton(
              icon: Icons.logout,
              label: 'Logout',
              subtitle: 'Sign out of your account',
              color: AppColors.error,
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                    ),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.domine(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to logout?',
                      style: GoogleFonts.domine(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.domine(color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.domine(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                
                if (shouldLogout == true) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(AppRouter.login);
                  }
                }
              },
            ),
            
            const SizedBox(height: 100), // Extra space for bottom nav
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? emoji,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.domine(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (emoji != null) ...[
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.domine(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
    String? badgeText,
    Color? badgeColor,
  }) {
    final iconColor = color ?? AppColors.primary;
    final textColor = color ?? AppColors.textPrimary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.domine(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? Colors.orange).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: badgeColor ?? Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.domine(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: badgeColor ?? Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.domine(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/router/app_router.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
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
        return Colors.orange;
      case 'LEAD':
        return Colors.purple;
      case 'MEMBER':
        return Colors.blue;
      default:
        return Colors.grey;
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: _isRefreshing 
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
                onPressed: _isRefreshing ? null : _refreshUserData,
                tooltip: 'Refresh profile data',
              ),
            ],
          ).animate().fadeIn(duration: 600.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'Manage your account and settings',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacityValue(0.8),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
          
          const SizedBox(height: 30),
          
          if (user != null) ...[
            // Compact Profile Header
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
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacityValue(0.3),
                            Colors.white.withOpacityValue(0.1),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.person, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacityValue(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 20),
            
            // Quick Info Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: _getRoleIcon(userRole),
                    label: 'Role',
                    value: _getRoleDisplayName(userRole),
                    color: _getRoleColor(userRole),
                  ),
                ),
                if (user.company != null) ...[
                  const SizedBox(width: 12),
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
              ],
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
            
            if (user.companyApprovalStatus != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.verified_user,
                label: 'Status',
                value: user.companyApprovalStatus!.toUpperCase(),
                color: _getStatusColor(user.companyApprovalStatus),
                emoji: _getStatusEmoji(user.companyApprovalStatus),
              ).animate().fadeIn(duration: 600.ms, delay: 350.ms),
            ],
            
            const SizedBox(height: 30),
            
            // Settings Section Title
            Text(
              'Settings',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
            
            const SizedBox(height: 16),
            
            // Personal Settings
            _buildSettingsButton(
              icon: Icons.person_outline,
              label: 'Personal Settings',
              subtitle: 'Edit your profile information',
              onTap: () => context.push(AppRouter.personalSettings),
            ).animate().fadeIn(duration: 600.ms, delay: 450.ms),
            
            const SizedBox(height: 12),
            
            // Lead Dashboard (Lead Only)
            if (userRole.toUpperCase() == 'LEAD') ...[
              _buildSettingsButton(
                icon: Icons.dashboard_outlined,
                label: 'Lead Dashboard',
                subtitle: 'Approve team materials',
                onTap: () => context.push(AppRouter.leadDashboard),
                badgeText: 'LEAD',
                badgeColor: Colors.purple,
              ).animate().fadeIn(duration: 600.ms, delay: 475.ms),
              
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
                badgeColor: Colors.orange,
              ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
              
              const SizedBox(height: 12),
              
              // Pending Approvals (Admin Only)
              _buildSettingsButton(
                icon: Icons.how_to_reg_outlined,
                label: 'Pending Approvals',
                subtitle: 'Review member join requests',
                onTap: () => context.push(AppRouter.manageApprovals),
                badgeText: 'ADMIN',
                badgeColor: Colors.orange,
              ).animate().fadeIn(duration: 600.ms, delay: 525.ms),
              
              const SizedBox(height: 12),
              
              // Team Management (Admin Only)
              _buildSettingsButton(
                icon: Icons.group_outlined,
                label: 'Team Management',
                subtitle: 'Manage company members',
                onTap: () => context.push(AppRouter.teamManagement),
                badgeText: 'ADMIN',
                badgeColor: Colors.orange,
              ).animate().fadeIn(duration: 600.ms, delay: 550.ms),
              
              const SizedBox(height: 12),
              
              // Hierarchy Management (Admin Only)
              _buildSettingsButton(
                icon: Icons.account_tree_outlined,
                label: 'Team Hierarchy',
                subtitle: 'Assign members to leads',
                onTap: () => context.push(AppRouter.hierarchyManagement),
                badgeText: 'ADMIN',
                badgeColor: Colors.orange,
              ).animate().fadeIn(duration: 600.ms, delay: 575.ms),
              
              const SizedBox(height: 12),
              
              // Batch Approvals (Admin Only)
              _buildSettingsButton(
                icon: Icons.approval_outlined,
                label: 'Batch Approvals',
                subtitle: 'Review and approve batches',
                onTap: () => context.push(AppRouter.adminBatchApproval),
                badgeText: 'ADMIN',
                badgeColor: Colors.orange,
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
              
              const SizedBox(height: 12),
            ],
            
            // Notification Settings
            _buildSettingsButton(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () => context.push(AppRouter.notificationSettings),
            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            
            const SizedBox(height: 12),
            
            // Privacy & Security
            _buildSettingsButton(
              icon: Icons.security_outlined,
              label: 'Privacy & Security',
              subtitle: 'Control your privacy settings',
              onTap: () => context.push(AppRouter.privacySettings),
            ).animate().fadeIn(duration: 600.ms, delay: 650.ms),
            
            const SizedBox(height: 12),
            
            // Help & Support
            _buildSettingsButton(
              icon: Icons.help_outline,
              label: 'Help & Support',
              subtitle: 'FAQs and contact support',
              onTap: () => context.push(AppRouter.helpSupport),
            ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
            
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
                    backgroundColor: AppColors.darkGreen,
                    title: Text(
                      'Logout',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    content: Text(
                      'Are you sure you want to logout?',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.poppins(color: AppColors.error),
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
            ).animate().fadeIn(duration: 600.ms, delay: 750.ms),
            
            const SizedBox(height: 100), // Extra space for bottom nav
          ],
        ],
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacityValue(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withOpacityValue(0.7),
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
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
    final textColor = color ?? Colors.white;
    
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
                color: (color ?? Colors.white).withOpacityValue(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: textColor, size: 24),
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
                        style: GoogleFonts.poppins(
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
                            color: (badgeColor ?? Colors.orange).withOpacityValue(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: textColor.withOpacityValue(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: textColor, size: 16),
          ],
        ),
      ),
    );
  }
}

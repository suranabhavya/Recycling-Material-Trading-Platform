import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:recycling_platform/features/business/data/models/user_detail_model.dart';

class UserCard extends ConsumerWidget {
  final UserDetailModel user;
  final bool readOnly;

  const UserCard({
    super.key,
    required this.user,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;
    final isOwnerOrAdmin = currentUser?.isAdmin ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: readOnly ? null : () {
            // TODO: Show user detail bottom sheet
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with name and action menu
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: GoogleFonts.domine(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name and email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.name,
                                  style: GoogleFonts.domine(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildUserTypeBadge(),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: GoogleFonts.domine(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Action menu (only for owner/admin and not read-only)
                    if (!readOnly && isOwnerOrAdmin)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                        ),
                        onSelected: (value) {
                          // TODO: Handle menu actions
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'assign_branch',
                            child: Row(
                              children: [
                                Icon(Icons.business, size: 18, color: AppColors.textSecondary),
                                SizedBox(width: 12),
                                Text('Assign Branch'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'assign_role',
                            child: Row(
                              children: [
                                Icon(Icons.badge, size: 18, color: AppColors.textSecondary),
                                SizedBox(width: 12),
                                Text('Assign Role'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'assign_manager',
                            child: Row(
                              children: [
                                Icon(Icons.supervisor_account, size: 18, color: AppColors.textSecondary),
                                SizedBox(width: 12),
                                Text('Assign Manager'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(Icons.person_remove, size: 18, color: AppColors.error),
                                SizedBox(width: 12),
                                Text('Remove User', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // User details
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    // Role
                    if (user.role != null)
                      _buildInfoChip(
                        icon: Icons.badge,
                        label: user.role!.name,
                        color: AppColors.primary,
                      ),

                    // Direct Manager
                    if (user.directManager != null)
                      _buildInfoChip(
                        icon: Icons.supervisor_account,
                        label: 'Reports to ${user.directManager!.name}',
                        color: AppColors.info,
                      ),

                    // Direct Reports Count
                    if (user.directReportsCount > 0)
                      _buildInfoChip(
                        icon: Icons.people,
                        label: '${user.directReportsCount} direct report${user.directReportsCount == 1 ? '' : 's'}',
                        color: AppColors.accent,
                      ),

                    // Verification status
                    if (!user.isVerified)
                      _buildInfoChip(
                        icon: Icons.warning,
                        label: 'Not verified',
                        color: AppColors.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeBadge() {
    IconData icon;
    Color color;
    String label;

    switch (user.userType) {
      case 'OWNER':
        icon = Icons.admin_panel_settings;
        color = AppColors.error;
        label = 'Owner';
        break;
      case 'ADMIN':
        icon = Icons.shield;
        color = AppColors.warning;
        label = 'Admin';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.domine(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.domine(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

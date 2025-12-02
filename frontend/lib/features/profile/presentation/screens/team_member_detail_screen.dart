import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:recycling_platform/features/company/presentation/providers/company_provider.dart';

class TeamMemberDetailScreen extends ConsumerWidget {
  final String memberId;
  final String memberName;
  final String memberEmail;
  final String memberRole;
  final String? createdAt;

  const TeamMemberDetailScreen({
    super.key,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.memberRole,
    this.createdAt,
  });

  String _getRoleDisplayName(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Administrator';
      case 'LEAD':
        return 'Team Lead';
      case 'MEMBER':
        return 'Member';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
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

  IconData _getRoleIcon(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return Icons.admin_panel_settings;
      case 'LEAD':
        return Icons.stars;
      case 'MEMBER':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else {
        return 'Today';
      }
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _updateRole(BuildContext context, WidgetRef ref, String newRole) async {
    final roleDisplayName = _getRoleDisplayName(newRole);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryDark,
        title: Text(
          'Update Role',
          style: GoogleFonts.domine(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to change $memberName\'s role to $roleDisplayName?',
          style: GoogleFonts.domine(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.domine(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Confirm',
              style: GoogleFonts.domine(color: _getRoleColor(newRole)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repository = ref.read(companyRepositoryProvider);
      await repository.updateUserRole(memberId, newRole);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$memberName\'s role updated to $roleDisplayName!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update role: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _kickMember(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryDark,
        title: Text(
          'Kick Member',
          style: GoogleFonts.domine(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to kick $memberName from the company? Their approval status will be set to REJECTED.',
          style: GoogleFonts.domine(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.domine(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Kick',
              style: GoogleFonts.domine(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repository = ref.read(companyRepositoryProvider);
      await repository.kickMember(memberId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$memberName has been kicked from the company'),
            backgroundColor: AppColors.warning,
          ),
        );
        context.pop(true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to kick member: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;
    final isCurrentUser = currentUser?.id == memberId;
    final isMemberAdmin = memberRole.toUpperCase() == 'ADMIN';
    final currentUserIsAdmin = currentUser?.roleTemplate?.name.toUpperCase() == 'ADMIN';

    // Redirect if not admin
    if (!currentUserIsAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Admin privileges required.'),
            backgroundColor: AppColors.error,
          ),
        );
      });
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColors.background),
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
                    Expanded(
                      child: Text(
                        'Team Member Details',
                        style: GoogleFonts.domine(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                      // Profile Card
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
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacityValue(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              // Avatar
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      _getRoleColor(memberRole).withOpacityValue(0.3),
                                      _getRoleColor(memberRole).withOpacityValue(0.1),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  _getRoleIcon(memberRole),
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Name
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      memberName,
                                      style: GoogleFonts.domine(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  if (isCurrentUser) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacityValue(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'You',
                                        style: GoogleFonts.domine(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Email
                              Text(
                                memberEmail,
                                style: GoogleFonts.domine(
                                  fontSize: 16,
                                  color: Colors.white.withOpacityValue(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Role Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(memberRole).withOpacityValue(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _getRoleColor(memberRole),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  _getRoleDisplayName(memberRole),
                                  style: GoogleFonts.domine(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              
                              if (createdAt != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Joined ${_formatDate(createdAt)}',
                                  style: GoogleFonts.domine(
                                    fontSize: 14,
                                    color: Colors.white.withOpacityValue(0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      // Only show actions if not current user and not admin
                      if (!isCurrentUser && !isMemberAdmin) ...[
                        const SizedBox(height: 32),
                        
                        Text(
                          'Role Management',
                          style: GoogleFonts.domine(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Promote to Admin
                        _buildActionButton(
                          icon: Icons.admin_panel_settings,
                          label: 'Promote to Admin',
                          subtitle: 'Grant full administrative access',
                          color: Colors.orange,
                          onTap: () => _updateRole(context, ref, 'ADMIN'),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Promote to Lead or Demote to Lead
                        if (memberRole.toUpperCase() != 'LEAD')
                          _buildActionButton(
                            icon: Icons.stars,
                            label: memberRole.toUpperCase() == 'MEMBER' 
                                ? 'Promote to Team Lead' 
                                : 'Demote to Team Lead',
                            subtitle: 'Grant team leadership privileges',
                            color: Colors.purple,
                            onTap: () => _updateRole(context, ref, 'LEAD'),
                          ),
                        
                        const SizedBox(height: 12),
                        
                        // Demote to Member
                        if (memberRole.toUpperCase() != 'MEMBER')
                          _buildActionButton(
                            icon: Icons.person,
                            label: 'Demote to Member',
                            subtitle: 'Remove leadership privileges',
                            color: Colors.blue,
                            onTap: () => _updateRole(context, ref, 'MEMBER'),
                          ),
                        
                        const SizedBox(height: 32),
                        
                        Text(
                          'Danger Zone',
                          style: GoogleFonts.domine(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Kick Member
                        _buildActionButton(
                          icon: Icons.person_remove,
                          label: 'Kick from Company',
                          subtitle: 'Remove member from the company',
                          color: AppColors.error,
                          onTap: () => _kickMember(context, ref),
                        ),
                      ],
                      
                      // Message for current user or admin
                      if (isCurrentUser || isMemberAdmin) ...[
                        const SizedBox(height: 32),
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
                                isCurrentUser ? Icons.info_outline : Icons.shield_outlined,
                                size: 48,
                                color: Colors.white.withOpacityValue(0.7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isCurrentUser 
                                    ? 'This is your profile' 
                                    : 'Admin accounts cannot be modified',
                                style: GoogleFonts.domine(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isCurrentUser
                                    ? 'You cannot modify your own role or kick yourself'
                                    : 'Only other admins can modify admin accounts',
                                style: GoogleFonts.domine(
                                  fontSize: 14,
                                  color: Colors.white.withOpacityValue(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
            color: color.withOpacityValue(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacityValue(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.domine(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.domine(
                      fontSize: 13,
                      color: Colors.white.withOpacityValue(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}



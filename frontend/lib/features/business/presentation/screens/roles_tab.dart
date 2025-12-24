import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:recycling_platform/features/business/data/models/user_detail_model.dart';
import 'package:recycling_platform/features/business/presentation/providers/roles_provider.dart';

class RolesTab extends ConsumerStatefulWidget {
  const RolesTab({super.key});

  @override
  ConsumerState<RolesTab> createState() => _RolesTabState();
}

class _RolesTabState extends ConsumerState<RolesTab> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch roles on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user?.companyId != null) {
        ref.read(rolesProvider.notifier).fetchCompanyRoles(user!.companyId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rolesState = ref.watch(rolesProvider);
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.isAdmin ?? false;

    // Filter roles based on search
    final filteredRoles = rolesState.roles.where((role) {
      return role.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (role.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    // Sort by user count (descending) then by name
    filteredRoles.sort((a, b) {
      final countCompare = b.userCount.compareTo(a.userCount);
      if (countCompare != 0) return countCompare;
      return a.name.compareTo(b.name);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search roles...',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${filteredRoles.length} role${filteredRoles.length == 1 ? '' : 's'}',
                        style: GoogleFonts.domine(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Roles list
          Expanded(
            child: rolesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : rolesState.error != null
                    ? Center(
                        child: Text(
                          rolesState.error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      )
                    : filteredRoles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No roles found',
                                  style: GoogleFonts.domine(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create roles to organize your team',
                                  style: GoogleFonts.domine(
                                    fontSize: 14,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredRoles.length,
                            itemBuilder: (context, index) {
                              final role = filteredRoles[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RoleCard(role: role),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Show create role dialog
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Role',
                style: GoogleFonts.domine(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}

class _RoleCard extends ConsumerWidget {
  final RoleModel role;

  const _RoleCard({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;
    final isAdmin = currentUser?.isAdmin ?? false;

    // Generate a color based on role name (for consistent colors)
    final colorIndex = role.name.hashCode.abs() % _roleColors.length;
    final roleColor = _roleColors[colorIndex];

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
          onTap: () {
            // TODO: Show role detail bottom sheet
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Role icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.badge,
                        color: roleColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Role name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.name,
                            style: GoogleFonts.domine(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (role.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              role.description!,
                              style: GoogleFonts.domine(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Action menu (only for admin)
                    if (isAdmin)
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
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18, color: AppColors.textSecondary),
                                SizedBox(width: 12),
                                Text('Edit Role'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: AppColors.error),
                                SizedBox(width: 12),
                                Text('Delete', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Role details
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: roleColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people,
                        size: 18,
                        color: roleColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${role.userCount} user${role.userCount == 1 ? '' : 's'} assigned',
                        style: GoogleFonts.domine(
                          fontSize: 14,
                          color: roleColor,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

// Color palette for roles
const List<Color> _roleColors = [
  AppColors.primary,
  AppColors.accent,
  AppColors.info,
  Color(0xFF8B7A99), // Purple
  Color(0xFF9B8450), // Brown
  Color(0xFF7A9B8B), // Teal
  Color(0xFFB67A8B), // Rose
  Color(0xFF8BB67A), // Light green
];

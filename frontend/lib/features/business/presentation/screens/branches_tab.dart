import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:recycling_platform/features/business/data/models/user_detail_model.dart';
import 'package:recycling_platform/features/business/presentation/providers/branches_provider.dart';

class BranchesTab extends ConsumerStatefulWidget {
  const BranchesTab({super.key});

  @override
  ConsumerState<BranchesTab> createState() => _BranchesTabState();
}

class _BranchesTabState extends ConsumerState<BranchesTab> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch branches on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user?.companyId != null) {
        ref.read(branchesProvider.notifier).fetchCompanyBranches(user!.companyId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final branchesState = ref.watch(branchesProvider);
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.isAdmin ?? false;

    // Filter branches based on search
    final filteredBranches = branchesState.branches.where((branch) {
      return branch.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (branch.city?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    // Sort: headquarters first, then by name
    filteredBranches.sort((a, b) {
      if (a.isHeadquarters && !b.isHeadquarters) return -1;
      if (!a.isHeadquarters && b.isHeadquarters) return 1;
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
                    hintText: 'Search branches...',
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
                        '${filteredBranches.length} branch${filteredBranches.length == 1 ? '' : 'es'}',
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

          // Branches list
          Expanded(
            child: branchesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : branchesState.error != null
                    ? Center(
                        child: Text(
                          branchesState.error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      )
                    : filteredBranches.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.business_outlined,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No branches found',
                                  style: GoogleFonts.domine(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredBranches.length,
                            itemBuilder: (context, index) {
                              final branch = filteredBranches[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _BranchCard(branch: branch),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Show create branch dialog
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Branch',
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

class _BranchCard extends ConsumerWidget {
  final BranchModel branch;

  const _BranchCard({required this.branch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;
    final isAdmin = currentUser?.isAdmin ?? false;

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
            // TODO: Show branch detail bottom sheet
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Branch icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: branch.isHeadquarters
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        branch.isHeadquarters ? Icons.home_work : Icons.business,
                        color: branch.isHeadquarters ? AppColors.primary : AppColors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Branch name and status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  branch.name,
                                  style: GoogleFonts.domine(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (branch.isHeadquarters) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'HQ',
                                        style: GoogleFonts.domine(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (!branch.isActive) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.error.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'Inactive',
                                    style: GoogleFonts.domine(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (branch.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              branch.description!,
                              style: GoogleFonts.domine(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
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
                                Text('Edit Branch'),
                              ],
                            ),
                          ),
                          if (branch.isActive)
                            const PopupMenuItem(
                              value: 'deactivate',
                              child: Row(
                                children: [
                                  Icon(Icons.block, size: 18, color: AppColors.warning),
                                  SizedBox(width: 12),
                                  Text('Deactivate'),
                                ],
                              ),
                            )
                          else
                            const PopupMenuItem(
                              value: 'activate',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, size: 18, color: AppColors.success),
                                  SizedBox(width: 12),
                                  Text('Activate'),
                                ],
                              ),
                            ),
                          if (!branch.isHeadquarters)
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

                // Branch details
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    // Location
                    if (branch.fullAddress.isNotEmpty)
                      _buildInfoChip(
                        icon: Icons.location_on,
                        label: branch.fullAddress,
                        color: AppColors.info,
                      ),

                    // Users count
                    _buildInfoChip(
                      icon: Icons.people,
                      label: '${branch.userCount} user${branch.userCount == 1 ? '' : 's'}',
                      color: AppColors.primary,
                    ),

                    // Materials count
                    _buildInfoChip(
                      icon: Icons.inventory_2,
                      label: '${branch.materialCount} material${branch.materialCount == 1 ? '' : 's'}',
                      color: AppColors.accent,
                    ),

                    // Contact
                    if (branch.phoneNumber != null)
                      _buildInfoChip(
                        icon: Icons.phone,
                        label: branch.phoneNumber!,
                        color: AppColors.textSecondary,
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
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.domine(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

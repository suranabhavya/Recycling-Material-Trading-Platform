import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:recycling_platform/features/business/presentation/providers/users_provider.dart';
import 'package:recycling_platform/features/business/presentation/widgets/user_card.dart';

class PeopleTab extends ConsumerStatefulWidget {
  final bool readOnly;

  const PeopleTab({super.key, this.readOnly = false});

  @override
  ConsumerState<PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends ConsumerState<PeopleTab> {
  String _searchQuery = '';
  String? _selectedBranchFilter;
  String? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    // Fetch users on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user?.companyId != null) {
        ref.read(usersProvider.notifier).fetchCompanyUsers(user!.companyId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersProvider);
    final user = ref.watch(authProvider).user;
    final isOwnerOrAdmin = user?.isAdmin ?? false;

    // Filter users based on search and filters
    var filteredUsers = usersState.users.where((u) {
      final matchesSearch = u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesBranch = _selectedBranchFilter == null ||
          u.branch?.name == _selectedBranchFilter;

      final matchesRole = _selectedRoleFilter == null ||
          u.role?.name == _selectedRoleFilter;

      return matchesSearch && matchesBranch && matchesRole;
    }).toList();

    // Group by branch
    final groupedUsers = <String, List>{};
    for (final u in filteredUsers) {
      final branchName = u.branch?.name ?? 'Unassigned';
      groupedUsers.putIfAbsent(branchName, () => []);
      groupedUsers[branchName]!.add(u);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
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

                // Filters row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${filteredUsers.length} people',
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

          // Users list
          Expanded(
            child: usersState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : usersState.error != null
                    ? Center(
                        child: Text(
                          usersState.error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      )
                    : filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No users found',
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
                            itemCount: groupedUsers.length,
                            itemBuilder: (context, index) {
                              final branchName = groupedUsers.keys.elementAt(index);
                              final branchUsers = groupedUsers[branchName]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Branch header
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 4,
                                      bottom: 12,
                                      top: index == 0 ? 0 : 24,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.business,
                                          size: 18,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$branchName (${branchUsers.length})',
                                          style: GoogleFonts.domine(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Users in this branch
                                  ...branchUsers.map((user) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: UserCard(
                                          user: user,
                                          readOnly: widget.readOnly,
                                        ),
                                      )),
                                ],
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: !widget.readOnly && isOwnerOrAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Show invite user dialog
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: Text(
                'Invite User',
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

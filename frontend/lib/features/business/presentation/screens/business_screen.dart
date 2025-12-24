import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/features/auth/data/models/user_model.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:recycling_platform/features/business/presentation/screens/branches_tab.dart';
import 'package:recycling_platform/features/business/presentation/screens/people_tab.dart';
import 'package:recycling_platform/features/business/presentation/screens/roles_tab.dart';
import 'package:recycling_platform/features/business/presentation/screens/settings_tab.dart';

class BusinessScreen extends ConsumerWidget {
  const BusinessScreen({super.key});

  int _getTabCount(UserModel? user) {
    final bool isAdmin = user?.isAdmin ?? false;
    if (isAdmin) return 4;
    return 1;
  }

  List<Tab> _getTabs(UserModel? user) {
    final bool isAdmin = user?.isAdmin ?? false;

    if (isAdmin) {
      return [
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people, size: 18),
              const SizedBox(width: 8),
              Text('People', style: GoogleFonts.domine()),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.business, size: 18),
              const SizedBox(width: 8),
              Text('Branches', style: GoogleFonts.domine()),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.badge, size: 18),
              const SizedBox(width: 8),
              Text('Roles', style: GoogleFonts.domine()),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings, size: 18),
              const SizedBox(width: 8),
              Text('Settings', style: GoogleFonts.domine()),
            ],
          ),
        ),
      ];
    }
    return [
      Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people, size: 18),
            const SizedBox(width: 8),
            Text('Directory', style: GoogleFonts.domine()),
          ],
        ),
      ),
    ];
  }

  List<Widget> _getTabViews(UserModel? user) {
    final bool isAdmin = user?.isAdmin ?? false;

    if (isAdmin) {
      return const [
        PeopleTab(),
        BranchesTab(),
        RolesTab(),
        SettingsTab(),
      ];
    }
    return const [
      PeopleTab(readOnly: true),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final tabCount = _getTabCount(user);

    // Debug: Print user info
    print('=== BusinessScreen Debug ===');
    print('User: ${user?.name}');
    print('User isAdmin: ${user?.isAdmin}');
    print('User roleTemplate: ${user?.roleTemplate}');
    print('Tab count: $tabCount');
    print('===========================');

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(
            'Business',
            style: GoogleFonts.domine(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: AppColors.surface,
              child: TabBar(
                tabs: _getTabs(user),
                isScrollable: true,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabAlignment: TabAlignment.start,
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: _getTabViews(user),
        ),
      ),
    );
  }
}

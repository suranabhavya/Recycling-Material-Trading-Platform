import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:recycling_platform/features/company/data/models/company_hierarchy_model.dart';
import 'package:recycling_platform/features/company/data/models/lead_model.dart';
import 'package:recycling_platform/features/company/data/models/team_member_model.dart';
import 'package:recycling_platform/features/company/presentation/providers/company_provider.dart';

class HierarchyManagementScreen extends ConsumerStatefulWidget {
  const HierarchyManagementScreen({super.key});

  @override
  ConsumerState<HierarchyManagementScreen> createState() => _HierarchyManagementScreenState();
}

class _HierarchyManagementScreenState extends ConsumerState<HierarchyManagementScreen> {
  CompanyHierarchyModel? _hierarchy;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHierarchy();
  }

  Future<void> _loadHierarchy() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = ref.read(authProvider).user;
      if (user?.companyId == null) {
        setState(() {
          _error = 'No company associated with your account';
          _isLoading = false;
        });
        return;
      }

      final repository = ref.read(companyRepositoryProvider);
      final hierarchy = await repository.getCompanyHierarchy(user!.companyId!);
      
      setState(() {
        _hierarchy = hierarchy;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load hierarchy: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.role?.toUpperCase() == 'ADMIN';
    
    // Redirect if not admin
    if (!isAdmin) {
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Team Hierarchy',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Manage team structure',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadHierarchy,
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 16),
                            Text(
                              'Loading hierarchy...',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacityValue(0.8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 60,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _error!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: _loadHierarchy,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      'Retry',
                                      style: GoogleFonts.poppins(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadHierarchy,
                            color: AppColors.primary,
                            backgroundColor: AppColors.darkGreen,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Admins Section
                                  _buildSectionHeader(
                                    'Admins',
                                    _hierarchy?.admins.length ?? 0,
                                    Icons.admin_panel_settings,
                                    Colors.orange,
                                  ),
                                  const SizedBox(height: 12),
                                  if (_hierarchy?.admins.isEmpty ?? true)
                                    _buildEmptyState('No admins found')
                                  else
                                    ..._hierarchy!.admins.asMap().entries.map((entry) {
                                      return _buildAdminCard(entry.value, entry.key);
                                    }),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Leads Section
                                  _buildSectionHeader(
                                    'Leads',
                                    _hierarchy?.leads.length ?? 0,
                                    Icons.stars,
                                    Colors.purple,
                                  ),
                                  const SizedBox(height: 12),
                                  if (_hierarchy?.leads.isEmpty ?? true)
                                    _buildEmptyState('No leads assigned yet')
                                  else
                                    ..._hierarchy!.leads.asMap().entries.map((entry) {
                                      return _buildLeadCard(entry.value, entry.key);
                                    }),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Unassigned Members Section
                                  _buildSectionHeader(
                                    'Unassigned Members',
                                    _hierarchy?.unassignedMembers.length ?? 0,
                                    Icons.person_outline,
                                    Colors.blue,
                                  ),
                                  const SizedBox(height: 12),
                                  if (_hierarchy?.unassignedMembers.isEmpty ?? true)
                                    _buildEmptyState('All members are assigned to leads')
                                  else
                                    ..._hierarchy!.unassignedMembers.asMap().entries.map((entry) {
                                      return _buildMemberCard(entry.value, entry.key, true);
                                    }),
                                ],
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacityValue(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacityValue(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacityValue(0.1),
            Colors.white.withOpacityValue(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacityValue(0.2),
          width: 1,
        ),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white.withOpacityValue(0.6),
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildAdminCard(AdminModel admin, int index) {
    final currentUser = ref.watch(authProvider).user;
    final isCurrentUser = admin.id == currentUser?.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacityValue(0.2),
            Colors.orange.withOpacityValue(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacityValue(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withOpacityValue(0.3),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        admin.name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacityValue(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'You',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  admin.email,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacityValue(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: (100 * index).ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildLeadCard(LeadModel lead, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacityValue(0.2),
            Colors.purple.withOpacityValue(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacityValue(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Lead Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.withOpacityValue(0.3),
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lead.email,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacityValue(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacityValue(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${lead.memberCount}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Team Members (if any)
          if (lead.teamMembers != null && lead.teamMembers!.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacityValue(0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: Colors.white.withOpacityValue(0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Team Members',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacityValue(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...lead.teamMembers!.asMap().entries.map((entry) {
                    return _buildMemberCard(entry.value, entry.key, false, leadId: lead.id);
                  }),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildMemberCard(
    TeamMemberModel member,
    int index,
    bool isUnassigned, {
    String? leadId,
  }) {
    return GestureDetector(
      onTap: isUnassigned
          ? () => _showAssignLeadDialog(member)
          : () => _showMemberOptions(member, leadId),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnassigned
              ? Colors.blue.withOpacityValue(0.1)
              : Colors.white.withOpacityValue(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnassigned
                ? Colors.blue.withOpacityValue(0.3)
                : Colors.white.withOpacityValue(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isUnassigned ? Colors.blue : Colors.white).withOpacityValue(0.2),
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.email,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withOpacityValue(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isUnassigned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacityValue(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Assign',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              Icon(
                Icons.more_vert,
                color: Colors.white.withOpacityValue(0.5),
                size: 16,
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (50 * index).ms);
  }

  Future<void> _showAssignLeadDialog(TeamMemberModel member) async {
    if (_hierarchy?.leads.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No leads available. Promote a member to Lead first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final selectedLead = await showDialog<LeadModel>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Assign ${member.name} to Lead',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _hierarchy!.leads.map((lead) {
            return ListTile(
              leading: const Icon(Icons.stars, color: Colors.purple),
              title: Text(
                lead.name,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              subtitle: Text(
                '${lead.memberCount} members',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacityValue(0.6),
                  fontSize: 12,
                ),
              ),
              onTap: () => Navigator.of(context).pop(lead),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (selectedLead != null) {
      await _assignMemberToLead(member.id, selectedLead.id);
    }
  }

  Future<void> _assignMemberToLead(String memberId, String leadId) async {
    if (!mounted) return;
    
    try {
      final repository = ref.read(companyRepositoryProvider);
      await repository.assignMemberToLead(memberId: memberId, leadId: leadId);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member assigned successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      _loadHierarchy();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign member: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showMemberOptions(TeamMemberModel member, String? leadId) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkGreen,
              AppColors.darkGreen.withOpacityValue(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacityValue(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      member.email,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacityValue(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.blue),
                title: Text(
                  'Reassign to Another Lead',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop('reassign');
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                title: Text(
                  'Unassign from Lead',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop('unassign');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );

    if (action == 'reassign') {
      await _showAssignLeadDialog(member);
    } else if (action == 'unassign') {
      await _unassignMember(member.id);
    }
  }

  Future<void> _unassignMember(String memberId) async {
    if (!mounted) return;
    
    try {
      final repository = ref.read(companyRepositoryProvider);
      await repository.unassignMemberFromLead(memberId);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member unassigned successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      _loadHierarchy();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unassign member: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}


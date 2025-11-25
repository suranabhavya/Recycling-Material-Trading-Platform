import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:recycling_platform/features/company/presentation/providers/company_provider.dart';

class TeamManagementScreen extends ConsumerStatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  ConsumerState<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends ConsumerState<TeamManagementScreen> {
  final _inviteFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _showInviteForm = false;
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
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
      final members = await repository.getCompanyMembers(user!.companyId!);
      
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load team members: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.roleTemplate?.isAdmin ?? false;

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
                            'Team Management',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Admin Only',
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
                      onPressed: _loadMembers,
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
                              'Loading team members...',
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
                                    onPressed: _loadMembers,
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
                            onRefresh: _loadMembers,
                            color: AppColors.primary,
                            backgroundColor: AppColors.darkGreen,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Invite New Member Section
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Team Members (${_members.length})',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => setState(() => _showInviteForm = !_showInviteForm),
                                        icon: Icon(_showInviteForm ? Icons.close : Icons.person_add, size: 18),
                                        label: Text(
                                          _showInviteForm ? 'Cancel' : 'Invite',
                                          style: GoogleFonts.poppins(fontSize: 14),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _showInviteForm ? Colors.red : AppColors.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(duration: 600.ms),
                                  
                                  if (_showInviteForm) ...[
                                    const SizedBox(height: 16),
                                    
                                    Container(
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
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacityValue(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Form(
                                        key: _inviteFormKey,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Invite Team Member',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            TextFormField(
                                              controller: _emailController,
                                              style: const TextStyle(color: Colors.white),
                                              keyboardType: TextInputType.emailAddress,
                                              decoration: InputDecoration(
                                                labelText: 'Email Address',
                                                labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                                prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacityValue(0.8)),
                                                filled: true,
                                                fillColor: Colors.white.withOpacityValue(0.1),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value?.isEmpty ?? true) return 'Email is required';
                                                if (!value!.contains('@')) return 'Invalid email';
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  if (_inviteFormKey.currentState?.validate() ?? false) {
                                                    // TODO: Implement invite member
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Invite feature coming soon!'),
                                                        backgroundColor: AppColors.warning,
                                                      ),
                                                    );
                                                    _emailController.clear();
                                                    setState(() => _showInviteForm = false);
                                                  }
                                                },
                                                icon: const Icon(Icons.send, color: Colors.white),
                                                label: Text(
                                                  'Send Invitation',
                                                  style: GoogleFonts.poppins(color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                                  backgroundColor: AppColors.primary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                                  ],
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Members List
                                  if (_members.isEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(40),
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
                                            Icons.group_outlined,
                                            size: 60,
                                            color: Colors.white.withOpacityValue(0.5),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No team members yet',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacityValue(0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Invite team members to collaborate',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.white.withOpacityValue(0.6),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ).animate().fadeIn(duration: 600.ms).scale()
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _members.length,
                                      itemBuilder: (context, index) {
                                        final member = _members[index];
                                        final isCurrentUser = member['id'] == user?.id;
                                        final roleTemplate = member['roleTemplate'] as Map<String, dynamic>?;
                                        final level = roleTemplate?['level'] as int?;
                                        final roleName = roleTemplate?['name'] as String?;
                                        final isMemberAdmin = level == 1;

                                        return _buildMemberCard(
                                          id: member['id'] as String,
                                          name: member['name'] as String,
                                          email: member['email'] as String,
                                          level: level,
                                          roleName: roleName,
                                          createdAt: member['createdAt'] as String?,
                                          isCurrentUser: isCurrentUser,
                                          isMemberAdmin: isMemberAdmin,
                                        ).animate().fadeIn(
                                          duration: 600.ms,
                                          delay: (100 * index).ms,
                                        ).slideX(begin: 0.2, end: 0);
                                      },
                                    ),
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

  Color _getRoleColor(int? level) {
    if (level == null) return Colors.grey;
    switch (level) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.blue;
      default:
        return Colors.teal;
    }
  }

  IconData _getRoleIcon(int? level) {
    if (level == null) return Icons.person_outline;
    switch (level) {
      case 1:
        return Icons.admin_panel_settings;
      case 2:
        return Icons.stars;
      case 3:
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  Future<void> _navigateToMemberDetail(Map<String, dynamic> member) async {
    final result = await context.push(
      '/team-member-detail',
      extra: member,
    );
    
    // Refresh if changes were made
    if (result == true) {
      _loadMembers();
    }
  }

  Widget _buildMemberCard({
    required String id,
    required String name,
    required String email,
    int? level,
    String? roleName,
    String? createdAt,
    required bool isCurrentUser,
    required bool isMemberAdmin,
  }) {
    return GestureDetector(
      onTap: () => _navigateToMemberDetail({
        'id': id,
        'name': name,
        'email': email,
        'level': level,
        'roleName': roleName,
        'createdAt': createdAt,
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacityValue(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _getRoleColor(level).withOpacityValue(0.3),
                    _getRoleColor(level).withOpacityValue(0.1),
                  ],
                ),
              ),
              child: Icon(
                _getRoleIcon(level),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacityValue(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'You',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
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
                    email,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacityValue(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(level).withOpacityValue(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      roleName?.toUpperCase() ?? 'NO ROLE',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacityValue(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

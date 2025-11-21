import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';

class TeamManagementScreen extends ConsumerStatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  ConsumerState<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends ConsumerState<TeamManagementScreen> {
  final _inviteFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _showInviteForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
                      // Invite New Member Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Team Members',
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
                      
                      // Current Team Members List
                      Text(
                        'Current Members',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                      
                      const SizedBox(height: 16),
                      
                      // Admin Member (Current User)
                      _buildMemberCard(
                        name: user?.name ?? 'Unknown',
                        email: user?.email ?? '',
                        role: 'ADMIN',
                        isCurrentUser: true,
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      // Empty State for Other Members
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
                              'No other members yet',
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
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 30),
                      
                      // Pending Invitations Section
                      Text(
                        'Pending Invitations',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                      
                      const SizedBox(height: 16),
                      
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
                              Icons.mail_outline,
                              size: 48,
                              color: Colors.white.withOpacityValue(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No pending invitations',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacityValue(0.7),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.2, end: 0),
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

  Widget _buildMemberCard({
    required String name,
    required String email,
    required String role,
    bool isCurrentUser = false,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacityValue(0.3),
                  Colors.white.withOpacityValue(0.1),
                ],
              ),
            ),
            child: Icon(
              role == 'ADMIN' ? Icons.admin_panel_settings : Icons.person,
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
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                    color: role == 'ADMIN' 
                        ? Colors.orange.withOpacityValue(0.3) 
                        : Colors.blue.withOpacityValue(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role,
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
          if (!isCurrentUser)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white.withOpacityValue(0.8)),
              color: AppColors.darkGreen,
              onSelected: (value) {
                if (value == 'remove') {
                  // TODO: Implement remove member
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Remove member feature coming soon!'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                } else if (value == 'promote') {
                  // TODO: Implement promote to admin
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Promote member feature coming soon!'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'promote',
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text('Promote to Admin', style: GoogleFonts.poppins(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      const Icon(Icons.person_remove, color: AppColors.error, size: 20),
                      const SizedBox(width: 12),
                      Text('Remove Member', style: GoogleFonts.poppins(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}


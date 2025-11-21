import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:recycling_platform/features/company/presentation/providers/company_provider.dart';

class ManageApprovalsScreen extends ConsumerStatefulWidget {
  const ManageApprovalsScreen({super.key});

  @override
  ConsumerState<ManageApprovalsScreen> createState() => _ManageApprovalsScreenState();
}

class _ManageApprovalsScreenState extends ConsumerState<ManageApprovalsScreen> {
  List<Map<String, dynamic>> _pendingUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingApprovals();
  }

  Future<void> _loadPendingApprovals() async {
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
      final pendingUsers = await repository.getPendingApprovals(user!.companyId!);
      
      setState(() {
        _pendingUsers = pendingUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load pending approvals: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGreen,
        title: Text(
          'Approve User',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to approve $userName?',
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
              'Approve',
              style: GoogleFonts.poppins(color: AppColors.success),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repository = ref.read(companyRepositoryProvider);
      await repository.approveUser(userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName approved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadPendingApprovals(); // Reload the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve user: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGreen,
        title: Text(
          'Reject User',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to reject $userName? This action cannot be undone.',
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
              'Reject',
              style: GoogleFonts.poppins(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repository = ref.read(companyRepositoryProvider);
      await repository.rejectUser(userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName rejected'),
            backgroundColor: AppColors.warning,
          ),
        );
        _loadPendingApprovals(); // Reload the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject user: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
                            'Pending Approvals',
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
                      onPressed: _loadPendingApprovals,
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
                              'Loading pending approvals...',
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
                                    onPressed: _loadPendingApprovals,
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
                        : _pendingUsers.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Container(
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
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 80,
                                          color: AppColors.success,
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'All Caught Up!',
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No pending approval requests at the moment.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: Colors.white.withOpacityValue(0.8),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ).animate().fadeIn(duration: 600.ms).scale(),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadPendingApprovals,
                                color: AppColors.primary,
                                backgroundColor: AppColors.darkGreen,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(24),
                                  itemCount: _pendingUsers.length,
                                  itemBuilder: (context, index) {
                                    final pendingUser = _pendingUsers[index];
                                    return _buildPendingUserCard(
                                      id: pendingUser['id'] as String,
                                      name: pendingUser['name'] as String,
                                      email: pendingUser['email'] as String,
                                      createdAt: pendingUser['createdAt'] as String?,
                                    ).animate().fadeIn(
                                      duration: 600.ms,
                                      delay: (100 * index).ms,
                                    ).slideX(begin: 0.2, end: 0);
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingUserCard({
    required String id,
    required String name,
    required String email,
    String? createdAt,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacityValue(0.3),
                      Colors.white.withOpacityValue(0.1),
                    ],
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacityValue(0.8),
                      ),
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Requested: ${_formatDate(createdAt)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacityValue(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectUser(id, name),
                  icon: const Icon(Icons.close, size: 20),
                  label: Text(
                    'Reject',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveUser(id, name),
                  icon: const Icon(Icons.check, size: 20),
                  label: Text(
                    'Approve',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }
}


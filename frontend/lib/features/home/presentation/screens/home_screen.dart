import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        return AppColors.success;
      case 'PENDING':
        return AppColors.warning;
      case 'REJECTED':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusEmoji(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        return '✅';
      case 'PENDING':
        return '⏳';
      case 'REJECTED':
        return '❌';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                Text(
                  '🌱 Gravita Platform',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 600.ms),
                
                const SizedBox(height: 10),
                
                Text(
                  'Metal Recycling Trading Platform',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacityValue(0.8),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                
                const SizedBox(height: 40),
                
                if (user != null) ...[
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacityValue(0.2),
                                ),
                                child: const Icon(Icons.person, size: 40, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.email,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withOpacityValue(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Divider(color: Colors.white.withOpacityValue(0.3), thickness: 1),
                          
                          const SizedBox(height: 24),
                          
                          // Role Badge
                          if (user.role != null) ...[
                            Row(
                              children: [
                                Icon(
                                  user.role == 'ADMIN' ? Icons.admin_panel_settings : Icons.person_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Role:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white.withOpacityValue(0.8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: user.role == 'ADMIN'
                                        ? const LinearGradient(
                                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                                          )
                                        : const LinearGradient(
                                            colors: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
                                          ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (user.role == 'ADMIN' ? Colors.red : Colors.blue).withOpacityValue(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    user.role == 'ADMIN' ? '👑 ADMIN' : '👤 MEMBER',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Company Info
                          if (user.company != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.business, color: Colors.white, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  'Company:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white.withOpacityValue(0.8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    user.company!.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Approval Status Badge
                          if (user.companyId != null) ...[
                            Row(
                              children: [
                                Icon(
                                  _getStatusIcon(user.companyApprovalStatus),
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Status:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white.withOpacityValue(0.8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(user.companyApprovalStatus),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getStatusColor(user.companyApprovalStatus).withOpacityValue(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${_getStatusEmoji(user.companyApprovalStatus)} ${user.companyApprovalStatus?.toUpperCase() ?? 'UNKNOWN'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 40),
                ],
                
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacityValue(0.2),
                        ),
                        child: const Icon(Icons.recycling, size: 80, color: Colors.white),
                      ).animate().scale(duration: 800.ms),
                      
                      const SizedBox(height: 40),
                      
                      Text(
                        'Welcome to Gravita! 🎉',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                      
                      const SizedBox(height: 20),
                      
                      Text(
                        'Start trading metal recycling materials',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacityValue(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                      
                      const SizedBox(height: 10),
                      
                      Text(
                        '(Dashboard coming soon...)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.accentOrange,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms, delay: 800.ms),
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


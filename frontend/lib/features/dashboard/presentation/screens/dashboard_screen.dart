import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 600.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'Welcome back, ${user?.name ?? "User"}!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacityValue(0.8),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
          
          const SizedBox(height: 30),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.inventory_2_rounded,
                  title: 'Total Scraps',
                  value: '0',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.pending_actions_rounded,
                  title: 'Pending',
                  value: '0',
                  color: AppColors.warning,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_rounded,
                  title: 'Approved',
                  value: '0',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.attach_money_rounded,
                  title: 'Total Value',
                  value: '₹0',
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 30),
          
          // Recent Activity
          Text(
            'Recent Activity',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          
          const SizedBox(height: 16),
          
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
                  Icons.inbox_rounded,
                  size: 60,
                  color: Colors.white.withOpacityValue(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No activity yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacityValue(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start adding scrap materials to see activity',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacityValue(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacityValue(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacityValue(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}


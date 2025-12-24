import 'package:flutter/material.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.add_circle_rounded,
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.business_rounded,
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 30,
              ),
              const SizedBox(height: 2),
              // Indicator dot
              // Container(
              //   width: 4,
              //   height: 4,
              //   decoration: BoxDecoration(
              //     color: isSelected ? AppColors.primary : Colors.transparent,
              //     shape: BoxShape.circle,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(35),
          // boxShadow: [
          //   BoxShadow(
          //     color: AppColors.shadow,
          //     blurRadius: 20,
          //     offset: const Offset(0, -5),
          //   ),
          // ],
        ),
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
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDarker : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppColors.primaryDarker,
          size: 28,
        ),
      ),
    );
  }
}

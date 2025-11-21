import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';

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
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacityValue(0.95),
              AppColors.primaryLight.withOpacityValue(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacityValue(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              index: 0,
            ),
            _buildNavItem(
              icon: Icons.add_circle_rounded,
              label: 'Add Scrap',
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacityValue(0.3)
                    : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacityValue(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isSelected ? 36 : 32,
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.poppins(
                fontSize: isSelected ? 14 : 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: Colors.white,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

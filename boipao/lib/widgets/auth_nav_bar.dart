import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A solid, non-transparent pill-shaped navigation bar specifically for the Auth flow.
class AuthNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AuthNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: AppColors.navBar,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavItem(Icons.login_rounded, "Sign In", 0),
          const SizedBox(width: 8),
          _buildNavItem(Icons.person_add_rounded, "Sign Up", 1),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.navBar : AppColors.secondary,
                size: 26,
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.navBar,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

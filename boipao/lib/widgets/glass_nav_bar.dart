import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A solid, non-transparent pill-shaped navigation bar.
///
/// Implements the user requirement where the nav bar is a solid dark pill.
/// Selected items get a white pill background and dynamically adjust width via AnimatedSize,
/// pushing other items aside smoothly.
class GlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const GlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35), // The entire navigation bar is a pill
        color: AppColors.navBar, // Completely solid black, no transparency 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_rounded, "Home", 0),
          _buildNavItem(Icons.search_rounded, "Search", 1),
          _buildNavItem(Icons.add_circle_outline_rounded, "Add", 2),
          _buildNavItem(Icons.person_rounded, "Profile", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      // We use AnimatedContainer for smooth background color switching
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent, // white pill background when selected
          borderRadius: BorderRadius.circular(25), // Pill shape for the inner selected item
        ),
        // AnimatedSize smoothly expands width when text is added, creating the 'pushing' effect
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

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/linear_gradient.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF15182d).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, Icons.home, "Sanctuary", activeIndex == 0, 0),
              _navItem(context, Icons.add, "Add", activeIndex == 1, 1),
              _navItem(context, Icons.show_chart, "Journey", activeIndex == 2, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool isActive, int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: isActive 
            ? BoxDecoration(
                color: AppColors.accentLavender.withValues(alpha: 0.8), 
                borderRadius: BorderRadius.circular(30)
              ) 
            : null,
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.white54, size: 24),
            if (isActive) const SizedBox(width: 8),
            if (isActive) 
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  static const Color _backgroundColor = Color(0xFF101820);
  static const Color _activeColor = Color(0xFF55C7FF);
  static const Color _inactiveColor = Color(0xFF6E7A85);
  static const Color _activeFillColor = Color(0xFF132C3D);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: _backgroundColor,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <_NavItemData>[
            _NavItemData(Icons.home_rounded, 'Home'),
            _NavItemData(Icons.card_travel_rounded, 'Challenges'),
            _NavItemData(Icons.shield_rounded, 'Ranking'),
            _NavItemData(Icons.favorite_rounded, 'News'),
            _NavItemData(Icons.person_rounded, 'Profile'),
            _NavItemData(Icons.more_horiz_rounded, 'More'),
          ].asMap().entries.map((entry) {
            final int index = entry.key;
            final _NavItemData item = entry.value;
            final bool isSelected = index == currentIndex;

            return Expanded(
              child: _BottomNavItem(
                icon: item.icon,
                label: item.label,
                isSelected: isSelected,
                onTap: () => onItemSelected(index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _activeColor = Color(0xFF55C7FF);
  static const Color _inactiveColor = Color(0xFF6E7A85);
  static const Color _activeFillColor = Color(0xFF132C3D);

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected ? _activeColor : _inactiveColor.withValues(alpha: 0.55);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _activeFillColor : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: isSelected
                ? Border.all(color: _activeColor.withValues(alpha: 0.30), width: 1.2)
                : null,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData(this.icon, this.label);

  final IconData icon;
  final String label;
}
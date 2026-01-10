import 'package:flutter/material.dart';

class NavBarItem {
  final Widget icon;
  final Widget activeIcon;
  final String label;
  final Widget screen;

  NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
  });
}

class ModernBottomNavBar extends StatelessWidget {
  final List<NavBarItem> items;
  final Function(int) onItemSelected;
  final int currentIndex;

  const ModernBottomNavBar({
    super.key,
    required this.items,
    required this.onItemSelected,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(50, 0, 50, 50),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          return GestureDetector(
            onTap: () => onItemSelected(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  IconTheme(
                    data: IconThemeData(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    child: isSelected
                        ? items[index].activeIcon
                        : items[index].icon,
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        items[index].label,
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

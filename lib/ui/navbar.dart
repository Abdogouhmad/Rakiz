import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:rakiz/core/context.dart';

class NavBarItem {
  final Widget icon;
  final Widget activeIcon;
  final String? label;
  final Widget screen;

  NavBarItem({
    required this.icon,
    required this.activeIcon,
    this.label,
    required this.screen,
  });
}

class Navbar extends StatelessWidget {
  final List<NavBarItem> items;
  final Function(int) onItemSelected;
  final int currentIndex;

  const Navbar({
    super.key,
    required this.items,
    required this.onItemSelected,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    // Define colors based on theme mode
    final tabBkcolor = isDark
        ? colorScheme.surface.withValues(alpha: 0.5)
        : colorScheme.primaryContainer;

    final containerBk = isDark
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHigh;

    final activeColor = isDark
        ? colorScheme.onPrimaryContainer
        : colorScheme.primary;
    final inactiveColor = colorScheme.onSurfaceVariant;

    return Padding(
      // Move the navbar up slightly and give it side margins for the "floating" look
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 35),
      child: Container(
        decoration: BoxDecoration(
          color: containerBk,
          borderRadius: BorderRadius.circular(100), // Rounded edges
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              // Using a standard subtle shadow
              color: colorScheme.shadow.withValues(alpha: 0.2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
            child: GNav(
              // Centers the tabs to reduce excessive spacing between them
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              rippleColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
              hoverColor: colorScheme.secondaryContainer.withValues(alpha: 0.5),

              gap: 8,

              // These apply to the text and default icon, but we use them
              // to guide our custom IconTheme below as well.
              activeColor: activeColor,
              color: inactiveColor, // Inactive color
              tabBorderRadius: 100,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInSine,

              tabBackgroundColor: tabBkcolor,

              selectedIndex: currentIndex,
              onTabChange: onItemSelected,

              tabs: items.asMap().entries.map((entry) {
                final int idx = entry.key;
                final NavBarItem item = entry.value;
                final bool isActive = idx == currentIndex;

                return GButton(
                  // We must provide an icon, but we hide it to use 'leading'
                  icon: Icons.circle_sharp,
                  iconSize: 0,

                  // Wrap custom widgets in IconTheme to enforce color changes
                  leading: IconTheme(
                    data: IconThemeData(
                      color: isActive ? activeColor : inactiveColor,
                      size: 24,
                    ),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: isActive ? item.activeIcon : item.icon,
                    ),
                  ),
                  text: item.label ?? "",
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ModernBottomNavBar extends StatefulWidget {
  final List<NavBarItem> items;
  final Function(int) onItemSelected;
  final int currentIndex;

  const ModernBottomNavBar({
    Key? key,
    required this.items,
    required this.onItemSelected,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  State<ModernBottomNavBar> createState() => _ModernBottomNavBarState();
}

class _ModernBottomNavBarState extends State<ModernBottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          widget.onItemSelected(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: widget.items
            .map(
              (item) =>
                  BottomNavigationBarItem(icon: item.icon, label: item.label),
            )
            .toList(),
      ),
    );
  }
}

class NavBarItem {
  final Widget icon;
  final String label;
  final Widget screen;

  NavBarItem({required this.icon, required this.label, required this.screen});
}

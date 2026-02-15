import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/ui/custom_text.dart';
import 'package:rakiz/ui/navbar.dart';
import 'package:rakiz/screens/timer/screen.dart';
import 'package:rakiz/screens/setting/screen.dart';

class MyHomePage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentMode;

  const MyHomePage({
    super.key,
    required this.onThemeChanged,
    required this.currentMode,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  // Changed to a getter so that when currentMode changes in the parent,
  // the SettingScreen inside this list also gets the new value.
  List<NavBarItem> get _navItems => [
    NavBarItem(
      icon: const Icon(Icons.timer_outlined),
      activeIcon: const Icon(Icons.timer_outlined),
      screen: const TimerScreen(),
    ),
    NavBarItem(
      icon: const Icon(Icons.settings_outlined),
      activeIcon: const Icon(Icons.settings_outlined),
      label: 'Settings',
      screen: SettingScreen(
        currentMode: widget.currentMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: UiText(
                text: "Settings", // No need to check index here anymore
                textAlign: TextAlign.center,
                type: UiTextType.headlineMedium,
                style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
              ),
              centerTitle: false,
            ),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          alignment: AlignmentGeometry.center,
          index: _currentIndex,
          children: _navItems.map((e) => e.screen).toList(),
        ),
      ),
      bottomNavigationBar: Navbar(
        items: _navItems,
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

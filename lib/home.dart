import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakiz/ui/custom_text.dart';
import 'package:rakiz/ui/navbar.dart';
import 'package:rakiz/screens/timer/screen.dart';
import 'package:rakiz/screens/setting/screen.dart';

class MyHomePage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const MyHomePage({super.key, required this.onThemeChanged});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  late final List<NavBarItem> _navItems = [
    NavBarItem(
      icon: const Icon(Icons.timer_outlined),
      activeIcon: const Icon(Icons.timer_outlined),
      label: 'Timer',
      screen: const TimerScreen(),
    ),
    NavBarItem(
      icon: const Icon(Icons.settings_outlined),
      activeIcon: const Icon(Icons.settings_outlined),
      label: 'Settings',
      screen: SettingScreen(onThemeChanged: widget.onThemeChanged),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: UiText(
          text: _currentIndex == 0 ? "Timer" : "Settings",
          textAlign: TextAlign.center,
          type: UiTextType.headlineMedium,
          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                alignment: AlignmentGeometry.center,
                index: _currentIndex,
                children: _navItems.map((e) => e.screen).toList(),
              ),
            ),
          ],
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

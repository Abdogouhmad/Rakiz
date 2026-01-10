import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:rakiz/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        const seed = Colors.deepPurple;

        final lightScheme =
            lightDynamic ?? ColorScheme.fromSeed(seedColor: seed);

        final darkScheme =
            darkDynamic ??
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);

        return MaterialApp(
          title: 'Rakiz',
          debugShowCheckedModeBanner: false,
          themeMode: _themeMode,
          theme: ThemeData(colorScheme: lightScheme, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
          home: MyHomePage(onThemeChanged: _changeTheme),
        );
      },
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _currentIndex = 0;

//   final List<NavBarItem> _navItems = [
//     NavBarItem(
//       icon: const Icon(Icons.timer_outlined),
//       activeIcon: const Icon(Icons.timer_outlined),
//       label: 'Focus',
//       screen: const TimerScreen(),
//     ),
//     NavBarItem(
//       icon: const Icon(Icons.settings_outlined),
//       activeIcon: const Icon(Icons.settings_outlined),
//       label: 'Settings',
//       screen: const SettingScreen(),
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 16.0),
//               child: UiText(
//                 text: _navItems[_currentIndex].label,
//                 textAlign: TextAlign.center,
//                 type: UiTextType.headlineMedium,
//                 style: GoogleFonts.robotoSlab(fontWeight: FontWeight.w600),
//               ),
//             ),
//             Expanded(
//               child: AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 200),
//                 child: _navItems[_currentIndex].screen,
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: ModernBottomNavBar(
//         items: _navItems,
//         currentIndex: _currentIndex,
//         onItemSelected: (index) {
//           setState(() => _currentIndex = index);
//         },
//       ),
//     );
//   }
// }

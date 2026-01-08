import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:rakiz/screens/timer/screen.dart';
import 'package:rakiz/screens/setting/screen.dart';
import 'package:rakiz/ui/custom_text.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        const Color defaultSeedColor = Colors.deepPurple;
        ColorScheme lightColorScheme =
            lightDynamic ?? ColorScheme.fromSeed(seedColor: defaultSeedColor);

        ColorScheme darkColorScheme =
            darkDynamic ??
            ColorScheme.fromSeed(
              seedColor: defaultSeedColor,
              brightness: Brightness.dark,
            );
        return MaterialApp(
          title: 'Rakiz',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP BAR: Stays at the top
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: UiText(
                text: "Focus",
                textAlign: TextAlign.center,
                type: UiTextType.headlineMedium,
                style: GoogleFonts.robotoSlab(fontWeight: FontWeight.w600),
              ),
            ),

            // 2. CENTER CONTENT: Expanded fills all available middle space
            Expanded(
              child: Center(
                // This Center widget ensures TimerScreen is dead-center
                // between the header and the bottom navigation
                child: const TimerScreen(),
              ),
            ),
          ],
        ),
      ),
      // 3. BOTTOM NAV AREA:
      // If you aren't using Scaffold(bottomNavigationBar: ...),
      // you can place your custom bottom nav widget here.
      // const MyCustomBottomNav(),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: 'Timer'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

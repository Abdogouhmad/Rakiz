import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:rakiz/home.dart';
// import 'package:rakiz/notification_service.dart';
import 'package:rakiz/alarm.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await NotificationService.init();
  await AlarmService.init();

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

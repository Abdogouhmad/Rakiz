import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:rakiz/home.dart';
import 'package:rakiz/screens/timer/service/alarm.dart';
import 'package:rakiz/screens/setting/service/appinfo.dart';
import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlarmService.init();
  await Appinfo.init();
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
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        const seed = Colors.deepPurple;

        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'Rakiz',
          debugShowCheckedModeBanner: false,
          themeMode: _themeMode,
          theme: ThemeData(
            colorScheme: lightDynamic ?? ColorScheme.fromSeed(seedColor: seed),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme:
                darkDynamic ??
                ColorScheme.fromSeed(
                  seedColor: seed,
                  brightness: Brightness.dark,
                ),
            useMaterial3: true,
          ),
          home: MyHomePage(onThemeChanged: _changeTheme),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:rakiz/home.dart';
import 'package:rakiz/screens/timer/service/alarm.dart';
import 'package:rakiz/screens/setting/service/appinfo.dart';
import 'package:flutter/services.dart';
import 'package:rakiz/screens/timer/service/notification.dart';
import 'package:rakiz/core/theme.dart';
import 'package:provider/provider.dart';
import 'package:rakiz/screens/setting/screens/timersettings/timer_config.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlarmService.init();
  await NotificationService.init();
  await Appinfo.init();

  // 1. Initialize the theme preference
  final themePrefs = ThemePreferance();
  await themePrefs.init();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TimerConfig())],
      child: MyApp(themePrefs: themePrefs),
    ),
  );
  // runApp(MyApp(themePrefs: themePrefs));
}

class MyApp extends StatefulWidget {
  // Add this line
  final ThemePreferance themePrefs;

  // Update the constructor to include themePrefs
  const MyApp({super.key, required this.themePrefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // You can REMOVE _themeMode and _changeTheme from here
  // because we will use widget.themePrefs instead.

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Use ListenableBuilder so the UI updates when the theme changes
    return ListenableBuilder(
      listenable: widget.themePrefs,
      builder: (context, _) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            const seed = Colors.deepPurple;

            return MaterialApp(
              navigatorKey: rootNavigatorKey,
              title: 'Rakiz',
              debugShowCheckedModeBanner: false,
              // Use the mode from your service
              themeMode: widget.themePrefs.mode,
              theme: ThemeData(
                colorScheme:
                    lightDynamic ?? ColorScheme.fromSeed(seedColor: seed),
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
              // Pass the update function from the service down to the children
              home: MyHomePage(
                onThemeChanged: widget.themePrefs.updateTheme,
                currentMode:
                    widget.themePrefs.mode, // Added this to help settings
              ),
            );
          },
        );
      },
    );
  }
}

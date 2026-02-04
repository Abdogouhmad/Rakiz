import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _key = "theme_mode";

  // Save the selection
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      mode.name,
    ); // Saves as "system", "light", or "dark"
  }

  // Load the selection
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    String? themeStr = prefs.getString(_key);

    // Map the string back to the Enum
    return ThemeMode.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => ThemeMode.system, // Default
    );
  }
}

class ThemePreferance extends ChangeNotifier {
  final ThemeService _service = ThemeService();
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  // Initialize and load from disk
  Future<void> init() async {
    _mode = await _service.loadThemeMode();
    notifyListeners();
  }

  // Update and save to disk
  void updateTheme(ThemeMode newMode) {
    _mode = newMode;
    _service.saveThemeMode(newMode);
    notifyListeners(); // This triggers the UI to rebuild
  }
}

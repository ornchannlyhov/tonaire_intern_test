import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system; // Default
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  // Load saved theme mode from secure storage
  Future<void> _loadThemeMode() async {
    try {
      final stored = await _storage.read(key: _themeKey);
      if (stored != null) {
        final index = int.tryParse(stored);
        if (index != null && index < ThemeMode.values.length) {
          _themeMode = ThemeMode.values[index];
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    }
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _storage.write(key: _themeKey, value: _themeMode.index.toString());
      notifyListeners();
    }
  }
}

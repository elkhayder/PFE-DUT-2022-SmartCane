import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  SharedPreferences? prefs;

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  set mode(ThemeMode value) {
    _mode = value;
    notifyListeners();

    String themeString = "";

    switch (value) {
      case ThemeMode.light:
        themeString = "light";
        break;

      case ThemeMode.system:
        themeString = "system";
        break;

      case ThemeMode.dark:
        themeString = "dark";
        break;
    }

    prefs?.setString("themeMode", themeString);
  }

  ThemeService() {
    getSavedValue();
  }

  void getSavedValue() async {
    prefs = await SharedPreferences.getInstance();

    ThemeMode theme = ThemeMode.system;

    switch (prefs?.getString("themeMode")) {
      case "light":
        theme = ThemeMode.light;
        break;

      case "dark":
        theme = ThemeMode.dark;
        break;
    }

    mode = theme;
  }
}

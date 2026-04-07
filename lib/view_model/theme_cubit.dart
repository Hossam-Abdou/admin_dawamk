import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  static ThemeCubit get(context) => BlocProvider.of(context);

  static const String _themeKey = 'theme_mode';

  void toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, newMode.toString());
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      if (savedTheme == ThemeMode.dark.toString()) {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.light);
      }
    }
  }
}

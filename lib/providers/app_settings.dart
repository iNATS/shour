import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier {
  static const _seedColorKey = 'seed_color';
  static const _defaultSeedColor = 0xFFE9605A;

  Color _seedColor = const Color(_defaultSeedColor);

  Color get seedColor => _seedColor;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _seedColor = Color(prefs.getInt(_seedColorKey) ?? _defaultSeedColor);
  }

  Future<void> setSeedColor(Color color) async {
    if (_seedColor.toARGB32() == color.toARGB32()) return;

    _seedColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.toARGB32());
  }
}

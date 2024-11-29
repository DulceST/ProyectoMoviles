import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Color _drawerColor = const Color(0xFF388E3C); // Color por defecto
  String _fontFamily = 'Roboto';

  Color get drawerColor => _drawerColor;
  String get fontFamily => _fontFamily;

  // Método para actualizar el color
  void setDrawerColor(Color color) async {
    _drawerColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('drawerColor', color.value); // Guardar en persistencia
  }

  // Método para cargar el color guardado
  Future<void> loadDrawerColor() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('drawerColor')) {
      _drawerColor = Color(prefs.getInt('drawerColor')!);
      notifyListeners();
    }
  }

  // Método para actualizar la fuente
  void setFontFamily(String fontFamily) async {
    _fontFamily = fontFamily;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('fontFamily', fontFamily); // Guardar fuente en persistencia
  }

  // Método para cargar la fuente guardada
  Future<void> loadFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('fontFamily')) {
      _fontFamily = prefs.getString('fontFamily') ?? 'Roboto'; // Valor por defecto si no existe
      notifyListeners();
    }
  }
}

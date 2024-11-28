import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Color _drawerColor = Colors.green[700]!; // Color por defecto

  Color get drawerColor => _drawerColor;

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
}

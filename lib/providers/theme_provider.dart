import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = Colors.green;
  String _fontFamily = 'Roboto';

  Color get primaryColor => _primaryColor;
  String get fontFamily => _fontFamily;

  // Devuelve un ThemeData que usa el color y fuente actuales
  ThemeData get themeData {
    return ThemeData(
      primaryColor: _primaryColor,
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontFamily: _fontFamily), // Estilo solo con la fuente
        bodyMedium: TextStyle(fontFamily: _fontFamily), // Estilo solo con la fuente
        bodySmall: TextStyle(fontFamily: _fontFamily), // Estilo solo con la fuente
        // Se pueden agregar más estilos de texto si es necesario, sin cambiar el tamaño
      ),
    );
  }

  void updateColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void updateFontFamily(String fontFamily) {
    _fontFamily = fontFamily;
    notifyListeners();
  }
}

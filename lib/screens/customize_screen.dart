import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_moviles/providers/theme_provider.dart';


class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizar Drawer'),
      ),
      body: GridView.count(
        crossAxisCount: 4,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.brown,
        ].map((color) {
          return GestureDetector(
            onTap: () {
              themeProvider.setDrawerColor(color); // Actualizar el color
              Navigator.pop(context); // Volver a la pantalla anterior
            },
            child: Container(
              color: color,
              child: const SizedBox.expand(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

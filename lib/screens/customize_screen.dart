import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_moviles/providers/theme_provider.dart';

class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    Color? selectedColor; // Para guardar temporalmente el color seleccionado

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizar colores y letras'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
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
                Colors.pink,
                Colors.teal,
                Colors.cyan,
              ].map((color) {
                return GestureDetector(
                  onTap: () {
                    selectedColor = color; // Guardar el color seleccionado
                  },
                  child: Container(
                    color: color,
                    child: selectedColor == color
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (selectedColor != null) {
                  themeProvider.setDrawerColor(selectedColor!); // Aplicar el color
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El color de la aplicacion ha sido actualizado'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor selecciona un color primero'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Aplicar cambios'),
            ),
          ),
        ],
      ),
    );
  }
}

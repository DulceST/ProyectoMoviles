import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_moviles/providers/theme_provider.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    Color? selectedColor = themeProvider.drawerColor;
    String selectedFont = themeProvider.fontFamily;  // Obtenemos la fuente seleccionada

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizar tema', style: TextStyle(color: Colors.white)),
        backgroundColor: themeProvider.drawerColor,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Selecciona un color para personalizar el tema:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 5,
              padding: const EdgeInsets.all(16.0),
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
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
                    themeProvider.setDrawerColor(color); 
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: selectedColor == color
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
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
          const Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              'Selecciona una fuente de letra:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Aquí agregamos la lista de fuentes disponibles para el usuario
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Roboto'),
                  onTap: () {
                    themeProvider.setFontFamily('Roboto'); // Establecer fuente Roboto
                  },
                  selected: selectedFont == 'Roboto',
                ),
                ListTile(
                  title: const Text('Arial'),
                  onTap: () {
                    themeProvider.setFontFamily('Arial'); // Establecer fuente Arial
                  },
                  selected: selectedFont == 'Arial',
                ),
                ListTile(
                  title: const Text('Times New Roman'),
                  onTap: () {
                    themeProvider.setFontFamily('Times New Roman'); // Establecer fuente Times New Roman
                  },
                  selected: selectedFont == 'Times New Roman',
                ),
                // Puedes agregar más opciones de fuentes aquí.
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'El tema ha sido actualizado',
                      style: TextStyle(fontSize: 16),
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Aplicar cambios', style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}

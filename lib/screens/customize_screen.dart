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
    Color? selectedColor  = themeProvider.drawerColor;

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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
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
              child: const Text('Aplicar cambios',style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}

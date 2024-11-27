/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_moviles/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Importar el Provider

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  _CustomizeScreenState createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  Color _selectedColor = Colors.green;
  String _selectedFont = 'Roboto';

  final List<String> _fonts = [
    'Roboto',
    'Lobster',
    'Open Sans',
    'Pacifico',
    'Raleway',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedColor = Color(prefs.getInt('selectedColor') ?? Colors.green.value);
      _selectedFont = prefs.getString('selectedFont') ?? 'Roboto';
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedColor', _selectedColor.value);
    await prefs.setString('selectedFont', _selectedFont);

    // Actualiza el ThemeProvider con los nuevos valores
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.updateColor(_selectedColor);
    themeProvider.updateFontFamily(_selectedFont);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizar'),
        backgroundColor: _selectedColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Selecciona un color:',
              style: TextStyle(fontSize: 18),
            ),
            Wrap(
              spacing: 10,
              children: [
                _buildColorOption(Colors.green),
                _buildColorOption(Colors.blue),
                _buildColorOption(Colors.red),
                _buildColorOption(Colors.purple),
                _buildColorOption(Colors.black),
                _buildColorOption(Colors.amber),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Tamaño de letra:',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _fonts.length,
                itemBuilder: (context, index) {
                  final font = _fonts[index];
                  return ListTile(
                    title: Text(
                      font,
                      style: GoogleFonts.getFont(font, fontSize: 18),
                    ),
                    trailing: _selectedFont == font
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedFont = font;
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _savePreferences();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferencias guardadas.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 20,
        child: _selectedColor == color
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }
}*/
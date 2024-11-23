import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          _buildPage(
            title: 'Bienvenido a la app',
            description: 'Te ayudaremos a reciclar de manera más eficiente.',
          ),
          _buildPage(
            title: 'Selecciona el material',
            description: 'Elige el material que reciclas más a menudo.',
          ),
          _buildPage(
            title: 'Completa tu perfil',
            description: 'Ingresa algunos datos para personalizar tu experiencia.',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isOnboardingCompleted', true);

          Navigator.pushReplacementNamed(context, '/home');
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildPage({required String title, required String description}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Text(description, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}

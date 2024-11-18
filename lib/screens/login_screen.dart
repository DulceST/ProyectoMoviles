import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proyecto_moviles/screens/home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == "ecoUser" && password == "ecoPassword") {
      // Navegar a la siguiente pantalla
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Credenciales incorrectas. Intenta nuevamente."),
      ));
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image.asset('assets/earth_logo.png', height: 150),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Lógica para recuperar la contraseña
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
                TextButton(
                  onPressed: () {
                    // Lógica para navegar a la pantalla de registro
                  },
                  child: const Text('Registrar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 20),
            // Enlaces para "Olvidé mi contraseña" y "Registrar"
            
            const SizedBox(height: 30),
            const Text('O inicia sesión con'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón de Google
                IconButton(
                  onPressed: () {
                    // Lógica para autenticarse con Google
                  },
                  icon: const FaIcon(FontAwesomeIcons.google),
                  iconSize: 40,
                ),
                const SizedBox(width: 20),
                // Botón de Facebook
                IconButton(
                  onPressed: () {
                    // Lógica para autenticarse con Facebook
                  },
                  icon: const FaIcon(FontAwesomeIcons.facebook),
                  iconSize: 40,
                ),
                const SizedBox(width: 20),
                // Botón de GitHub
                IconButton(
                  onPressed: () {
                    // Lógica para autenticarse con GitHub
                  },
                  icon: const FaIcon(FontAwesomeIcons.github),
                  iconSize: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
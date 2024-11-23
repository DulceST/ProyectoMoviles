import 'package:animated_floating_buttons/widgets/animated_floating_action_button.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final GlobalKey<AnimatedFloatingActionButtonState> key =GlobalKey<AnimatedFloatingActionButtonState>();

String email = ''; // Aquí almacenaremos el correo

  @override
  void initState() {
    super.initState();
    _getEmail(); // Obtener el correo cuando se inicie la pantalla
  }

  // Método para obtener el correo desde Firebase
  Future<void> _getEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? 'Correo no disponible';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Fondo verde en la AppBar
        
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green[700], // Fondo verde oscuro en el DrawerHeader
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.green), // Ícono verde
              title: const Text('Perfil', style: TextStyle(color: Colors.green)), // Texto verde
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens, color: Colors.green), // Ícono verde
              title: const Text('Cambiar colores y letras', style: TextStyle(color: Colors.green)), // Texto verde
              onTap: () {
                Navigator.pushNamed(context, '/changeColors'); // Navegar a la pantalla de cambiar colores
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.green), // Ícono verde
              title: const Text('Cerrar sesión', style: TextStyle(color: Colors.green)), // Texto verde
              onTap: () async {
                // Cerrar sesión en Firebase
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login'); // Redirigir a la pantalla de login
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.green, // Fondo verde en el ConvexAppBar
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.map, title: 'Recycling Map'),
          TabItem(icon: Icons.exit_to_app, title: 'Exit'),
        ],
        initialActiveIndex: 0,
        onTap: (int index) {
          if (index == 1) {
            Navigator.pushNamed(context, "/recycling_map");
          }
        },
      ),
    );
  }
}
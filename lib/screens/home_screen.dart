import 'package:animated_floating_buttons/widgets/animated_floating_action_button.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles/screens/information_screen.dart';
import 'package:proyecto_moviles/screens/recycling_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<AnimatedFloatingActionButtonState> key =
      GlobalKey<AnimatedFloatingActionButtonState>();

  String email = ''; // Aquí almacenaremos el correo
  int _currentIndex = 0; // Controla la pantalla actual

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

  // Métodos para obtener las pantallas
  final List<Widget> _pages = [
    const Center(child: Text('Bienvenido a Home', style: TextStyle(fontSize: 20))),
    RecyclingMapScreen(), // Widget para el mapa
    InformationScreen(), // Widget para la información
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Fondo verde en la AppBar
        title: const Text('Reciclaje'),
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
              title: const Text('Cambiar colores y letras',
                  style: TextStyle(color: Colors.green)), // Texto verde
              onTap: () {
                Navigator.pushNamed(context, '/changeColors'); // Navegar a la pantalla de cambiar colores
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.green), // Ícono verde
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.green)), // Texto verde
              onTap: () async {
                // Cerrar sesión en Firebase
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login'); // Redirigir a la pantalla de login
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex, // Muestra la pantalla correspondiente al índice
        children: _pages,
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.green, // Fondo verde en el ConvexAppBar
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.map, title: 'Recycling Map'),
          TabItem(icon: Icons.info_rounded, title: 'Informacion'),
        ],
        initialActiveIndex: 0,
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Cambia la pantalla al índice seleccionado
          });
        },
      ),
    );
  }
}

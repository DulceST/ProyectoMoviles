import 'package:animated_floating_buttons/widgets/animated_floating_action_button.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles/screens/information_screen.dart';
import 'package:proyecto_moviles/screens/recycling_map_screen.dart';
import 'package:proyecto_moviles/screens/active_events.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<AnimatedFloatingActionButtonState> key =
      GlobalKey<AnimatedFloatingActionButtonState>();

  String email = 'Cargando...'; // Correo del usuario
  String? photoUrl; // Foto de perfil
  String providerId = 'Desconocido'; // Proveedor de autenticación
  int _currentIndex = 0; // Controla la pantalla actual

  @override
  void initState() {
    super.initState();
    _getUserData(); // Obtener los datos del usuario
  }

  // Método para obtener los datos del usuario desde Firebase
  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        email = user.email ?? 'Correo no disponible';
        photoUrl = user.photoURL ??
            'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/default-avatar.png';
        providerId = user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'Desconocido';
      });
    }
  }

  // Métodos para obtener las pantallas
  final List<Widget> _pages = [
    InformationScreen(), // Widget para la información
    const RecyclingMapScreen(), // Widget para el mapa
    ActiveEventsScreen(), // Widget para eventos activos
  ];

  @override
  Widget build(BuildContext context) {
    // Mapear proveedor de autenticación a logotipos
    Map<String, String> providerLogos = {
      'google.com': 'assets/google.png',
      'facebook.com': 'assets/facebook.png',
      'github.com': 'assets/github.png',
      'password': 'assets/email.png',
    };

    String? providerLogo = providerLogos[providerId];

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
              child: Row(
                children: [
                  // Mostrar foto del usuario
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(photoUrl ??
                        'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/default-avatar.png'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mostrar correo y logo del proveedor en una fila
                        Row(
                          children: [
                            if (providerLogo != null)
                              Image.asset(
                                providerLogo,
                                height: 20,
                              ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.account_circle, color: Colors.green), // Ícono verde
              title: const Text('Perfil',
                  style: TextStyle(color: Colors.green)), // Texto verde
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
              leading: const Icon(Icons.color_lens, color: Colors.green), // Ícono verde
              title: const Text('Agregar un evento',
                  style: TextStyle(color: Colors.green)), // Texto verde
              onTap: () {
                Navigator.pushNamed(context, '/add_event'); // Navegar a la pantalla de cambiar colores
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
          TabItem(icon: Icons.info_rounded, title: 'Informacion'),
          TabItem(icon: Icons.map, title: 'Recycling Map'),
          TabItem(icon: Icons.event, title: 'Eventos'),
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

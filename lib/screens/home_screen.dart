import 'package:animated_floating_buttons/widgets/animated_floating_action_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_moviles/providers/theme_provider.dart';
import 'package:proyecto_moviles/screens/information_screen.dart';
import 'package:proyecto_moviles/screens/recycling_map_screen.dart';
import 'package:proyecto_moviles/screens/active_events.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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
        
        photoUrl = user.photoURL ??
            'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/default-avatar.png';
        providerId = user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'Desconocido';
      });
    }
  }

  /// Función para obtener los datos del usuario
  Future<Map<String, dynamic>> _getinfo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw 'Usuario no autenticado';

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) throw 'No se encontraron datos del usuario';

      return userDoc.data()!;
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      throw e;
    }
  }

  // Métodos para obtener las pantallas
  final List<Widget> _pages = [
    InformationScreen(), // Widget para la información
    RecyclingMapScreen(), // Widget para el mapa
    const ActiveEventsScreen(), // Widget para eventos activos
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.drawerColor, // Fondo verde en la AppBar
        title: const Text('VidaVerde', style: TextStyle(color: Colors.white)),
      ),
      drawer: Drawer(
        child: FutureBuilder<Map<String, dynamic>>(
          future:
              _getinfo(), // Llama a la función que obtiene los datos del usuario
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No se encontraron datos'));
            }

            final userData = snapshot.data!;
            final photoUrl = userData['profileImage'] ??
                'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/default-avatar.png';
            
            final userName = userData['user'] ?? 'Usuario desconocido';
            

            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: themeProvider
                        .drawerColor, // Fondo verde oscuro en el DrawerHeader
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(photoUrl),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading:
                      const Icon(Icons.account_circle, color: Colors.black),
                  title: const Text('Perfil',
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens, color: Colors.black),
                  title: const Text('Cambiar colores y letras',
                      style: TextStyle(color: Colors.black)),
                  onTap: () async {
                    // Verificar si el usuario tiene una suscripción activa
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please log in to access this option.')),
                      );
                      return; // Si el usuario no está logueado, no continuar
                    }

                    // Obtener la suscripción del usuario
                    try {
                      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

                      if (userDoc.exists) {
                        final userSubscription = userDoc.data() as Map<String, dynamic>;
                        final subscription = userSubscription['pay_subscription'];

                        if (subscription != null && subscription['expiryDate'] != null) {
                          DateTime expiryDate = DateTime.parse(subscription['expiryDate']);
                          if (expiryDate.isAfter(DateTime.now())) {
                            // Si la suscripción está activa, navegar a la pantalla de colores
                            Navigator.pushNamed(context, '/color');
                          } else {
                            // Si la suscripción ha expirado, mostrar una alerta
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: 'Subscription Expired',
                              text: 'Your subscription has expired. Please renew it.',
                              confirmBtnText: 'Renew',
                              onConfirmBtnTap: () {
                                // Aquí puedes navegar a la pantalla de suscripción
                                Navigator.pushNamed(context, '/subscription');
                              },
                            );
                          }
                        } else {
                          // Si no hay suscripción activa, mostrar alerta con QuickAlert
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: 'No Active Subscription',
                            text: 'You need an active subscription to access this option.',
                            confirmBtnText: 'Get Subscription',
                            onConfirmBtnTap: () {
                              // Aquí puedes navegar a la pantalla de suscripción
                              Navigator.pushNamed(context, '/products');
                            },
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('User data not found.')),
                        );
                      }
                    } catch (e) {
                      print('Error checking subscription: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('An error occurred. Please try again later.')),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event, color: Colors.black),
                  title: const Text('Agregar un evento',
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.pushNamed(context, '/add_event');
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.workspace_premium, color: Colors.black),
                  title: const Text('Hazte premium',
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.pushNamed(context, '/products');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.black),
                  title: const Text('Cerrar sesión',
                      style: TextStyle(color: Colors.black)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: IndexedStack(
        index: _currentIndex, // Muestra la pantalla correspondiente al índice
        children: _pages,
      ),
      bottomNavigationBar: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ConvexAppBar(
            backgroundColor: themeProvider.drawerColor,
            items: const [
              TabItem(icon: Icons.info_rounded, title: 'Información'),
              TabItem(icon: Icons.map, title: 'Recycling Map'),
              TabItem(icon: Icons.event, title: 'Eventos'),
            ],
            initialActiveIndex: 0,
            onTap: (int index) {
              setState(() {
                _currentIndex =
                    index; // Cambia la pantalla al índice seleccionado
              });
            },
          );
        },
      ),
    );
  }
}

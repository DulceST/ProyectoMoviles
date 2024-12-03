import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_moviles/providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<DocumentSnapshot> _getUserData() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('Usuario no autenticado');
    }

    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<void> _updateUserData(BuildContext context, String field, String value) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('Usuario no autenticado');
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      field: value,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos actualizados correctamente')),
    );
  }

  void _showUpdateDialog(
      BuildContext context, String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Actualizar $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _updateUserData(context, field.toLowerCase(), controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  String _getAuthProviderName(User user) {
    if (user.providerData.isNotEmpty) {
      return user.providerData.first.providerId;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: themeProvider.drawerColor,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No se encontraron datos del usuario.'),
            );
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var user = FirebaseAuth.instance.currentUser;

          String userName = userData['user'] ?? 'No disponible';
          String phone = userData['phone'] ?? 'No disponible';
          String profileImage = userData['profileImage'] ??
              'https://via.placeholder.com/150';
          String subscriptionExpiry =
              userData['subscriptionExpiry'] ?? 'No disponible';

          String provider = _getAuthProviderName(user!);
          String providerImage = _getProviderImage(provider);

          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  lightenColor(themeProvider.drawerColor, 0.4),
                  lightenColor(themeProvider.drawerColor, 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(profileImage),
                  backgroundColor: lightenColor(themeProvider.drawerColor, 0.4),
                ),
                const SizedBox(height: 20),
                _buildProviderRow(
                    providerImage, user.email ?? 'No disponible', context),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildInfoCard(
                          'Usuario', userName, Icons.person, context, () {
                        _showUpdateDialog(context, 'Usuario', userName);
                      }),
                      _buildInfoCard('Teléfono', phone, Icons.phone, context,
                          () {
                        _showUpdateDialog(context, 'Teléfono', phone);
                      }),
                      _buildInfoCard(
                          'Expiración de Suscripción',
                          subscriptionExpiry,
                          Icons.calendar_today,
                          context,
                          () {
                        _showUpdateDialog(
                            context, 'Expiración de Suscripción', subscriptionExpiry);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProviderRow(
      String providerImage, String email, BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(providerImage, width: 50, height: 50),
        const SizedBox(width: 10),
        Text(
          email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: darkenColor(themeProvider.drawerColor, 0.3),
              ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon,
      BuildContext context, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lightenColor(themeProvider.drawerColor, 0.4),
          child: Icon(
            icon,
            color: darkenColor(themeProvider.drawerColor, 0.2),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: darkenColor(themeProvider.drawerColor, 0.3),
              ),
        ),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: darkenColor(themeProvider.drawerColor, 0.1),
              ),
        ),
      ),
    );
  }

  String _getProviderImage(String provider) {
    switch (provider) {
      case 'google.com':
        return 'assets/google.png';
      case 'facebook.com':
        return 'assets/facebook.png';
      case 'github.com':
        return 'assets/github.png';
      case 'password':
        return 'assets/email.png';
      default:
        return 'assets/email.png';
    }
  }

  Color darkenColor(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final darkerHsl =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkerHsl.toColor();
  }

  Color lightenColor(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lighterHsl =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lighterHsl.toColor();
  }
}

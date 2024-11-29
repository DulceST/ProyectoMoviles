import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_moviles/providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Obtener el email del usuario autenticado
  Future<DocumentSnapshot> _getUserData() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('Usuario no autenticado');
    }

    // Obtener los datos del usuario desde Firestore
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
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
                child: Text('No se encontraron datos del usuario.'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          String userName = userData['user'] ?? 'No disponible';
          String phone = userData['phone'] ?? 'No disponible';
          String country = userData['country'] ?? 'No disponible';
          String state = userData['state'] ?? 'No disponible';
          String city = userData['city'] ?? 'No disponible';
          String profileImage = userData['profileImage'] ??
              'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/default-avatar.png';

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen de perfil
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(profileImage),
                  backgroundColor: lightenColor(themeProvider.drawerColor, 0.4),
                ),
                const SizedBox(height: 20),
                // Nombre del usuario
                Text(
                  userName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: darkenColor(themeProvider.drawerColor, 0.4),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                Divider(
                    color: darkenColor(themeProvider.drawerColor, 0.2),
                    thickness: 1),
                const SizedBox(height: 20),
                // Tarjeta de información
                Expanded(
                  child: ListView(
                    children: [
                      _buildInfoCard('Teléfono', phone, Icons.phone, context),
                      _buildInfoCard('País', country, Icons.flag, context),
                      _buildInfoCard(
                          'Estado', state, Icons.location_city, context),
                      _buildInfoCard(
                          'Ciudad', city, Icons.location_on, context),
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

  Widget _buildInfoCard(
      String title, String value, IconData icon, BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: lightenColor(themeProvider.drawerColor, 0.4),
              child: Icon(
                icon,
                color: darkenColor(themeProvider.drawerColor, 0.2),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: darkenColor(themeProvider.drawerColor, 0.3),
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: darkenColor(themeProvider.drawerColor, 0.1),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

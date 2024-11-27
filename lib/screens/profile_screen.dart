import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getUserData(),
        builder: (context, snapshot) {
          // Verificar si los datos se están cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Verificar si ocurrió un error al obtener los datos
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Verificar si no se encontró ningún documento
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No se encontraron datos del usuario.'));
          }

          // Obtener los datos del documento
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          String userName = userData['user'] ?? 'No disponible';
          String phone = userData['phone'] ?? 'No disponible';
          String country = userData['country'] ?? 'No disponible';
          String state = userData['state'] ?? 'No disponible';
          String city = userData['city'] ?? 'No disponible';
          String profileImage = userData['profileImage'] ?? 'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/default-avatar.png';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar la imagen de perfil
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profileImage),
                ),
                const SizedBox(height: 20),
                Text('Nombre: $userName', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text('Teléfono: $phone', style: Theme.of(context).textTheme.bodyMedium),  // Cambiado de bodyText1 a bodyMedium
                const SizedBox(height: 10),
                Text('País: $country', style: Theme.of(context).textTheme.bodyMedium),  // Cambiado de bodyText1 a bodyMedium
                const SizedBox(height: 10),
                Text('Estado: $state', style: Theme.of(context).textTheme.bodyMedium),  // Cambiado de bodyText1 a bodyMedium
                const SizedBox(height: 10),
                Text('Ciudad: $city', style: Theme.of(context).textTheme.bodyMedium),  // Cambiado de bodyText1 a bodyMedium
              ],
            ),
          );
        },
      ),
    );
  }
}

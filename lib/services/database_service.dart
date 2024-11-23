import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inserción de datos del usuario
  Future<void> addUser({
    required String userId,
    required String userName,
    required String email,
    required String phone,
    required String country,
    required String state,
    required String city,
    required List<String> materials,
    String? avatarUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'user': userName,
        'email': email,
        'phone': phone,
        'country': country,
        'state': state,
        'city': city,
        'materials': materials,
        'avatarUrl': avatarUrl ??
            'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/default-avatar.png',
      });
    } catch (e) {
      throw Exception('Error al agregar usuario: $e');
    }
  }

  // Actualización de datos del usuario
  Future<void> updateUser({
    required String userId,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update(data ?? {});
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  // Eliminación de un usuario
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  // Obtener los datos de un usuario por ID
  Future<DocumentSnapshot> getUser(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      throw Exception('Error al obtener datos del usuario: $e');
    }
  }

  // Consultar todos los usuarios
  Future<QuerySnapshot> getAllUsers() async {
    try {
      return await _firestore.collection('users').get();
    } catch (e) {
      throw Exception('Error al obtener la lista de usuarios: $e');
    }
  }
}

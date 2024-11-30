import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class EmailAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<int?> createAccount(
      String email, String password, BuildContext context) async {
    try {
      // Crear un nuevo usuario con correo y contraseña
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar información del usuario en Firestore
      await FirebaseFirestore.instance.collection('account').doc(email).set({
        'onboarding': false,
        'email': email,
        'isVerified': false,
      });

      print(userCredential);
      return 0; // Cuenta creada con éxito
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 1; // Contraseña débil
      } else if (e.code == 'email-already-in-use') {
        return 2; // El correo ya está en uso
      } else if (e.code == 'invalid-email') {
        return 3; // Correo inválido
      }
    } catch (e) {
      print(e); // Manda el error
    }
    return null;
  }

  Future<int?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print("Inicio de sesión exitoso: ${userCredential.user?.email}");
      return 0; // Inicio de sesión exitoso
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('Usuario no encontrado.');
        return 1; // Usuario no encontrado
      } else if (e.code == 'wrong-password') {
        print('Contraseña incorrecta.');
        return 2; // Contraseña incorrecta
      } else if (e.code == 'too-many-requests') {
        print('Demasiados intentos. Inténtalo más tarde.');
        return 3; // Demasiados intentos
      } else {
        print('Error: ${e.message}');
        return 4; // Error desconocido
      }
    } catch (e) {
      print('Error general: $e');
      return 5; // Error general
    }
  }
  // Método para enviar el correo de verificación
  Future<void> sendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        // Si el usuario está autenticado y el correo no ha sido verificado
        await user.sendEmailVerification();
        print("Correo de verificación enviado a ${user.email}");
      } else {
        print("El usuario ya ha verificado su correo o no está autenticado.");
      }
    } catch (e) {
      print("Error al enviar el correo de verificación: $e");
    }
  }

  // Método para verificar si el correo está validado
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Verificar si el correo está validado
      return user.emailVerified;
    } else {
      print("No hay un usuario autenticado.");
      return false;  // Si no hay un usuario autenticado, devuelve false
    }
  }
}


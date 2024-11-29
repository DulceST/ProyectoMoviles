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

  Future<int> signInEmailAndPassword(String email, String password) async {

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (userCredential.user != null) {
        return 0; // Éxito
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("Usuario no encontrado");
        return 1; // Usuario no encontrado
      } else if (e.code == 'wrong-password') {
        print("Contraseña incorrecta");
        return 2; // Contraseña incorrecta
      } else if (e.code == 'invalid-email') {
        print("Correo electrónico no válido");
        return 3; // Correo no válido
      } else {
        print("Error desconocido: ${e.message}");
        return 4; // Error desconocido
      }
    } catch (e) {
      print("Error general: $e");
      return 5; // Otro error
    }
    return 3; // Valor por defecto si no se captura ningún caso
  }

  Future<void> sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Correo de verificación enviado');
      } else if (user?.emailVerified ?? false) {
        print('Tu correo ya ha sido verificado.');
      } else {
        print('No se ha encontrado un usuario autenticado.');
      }
    } catch (e) {
      print('Error al enviar el correo de verificación: $e');
    }
  }

  Future<void> checkEmailVerification() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Esperar a que el correo sea verificado
    while (user!.emailVerified) {
      await Future.delayed(const Duration(seconds: 1)); // Espera un segundo y verifica de nuevo
      await user.reload(); // Recarga el estado del usuario
      user = FirebaseAuth.instance.currentUser; // Obtiene el usuario actualizado
    }

    // Si el correo está verificado, actualizamos Firestore
    await FirebaseFirestore.instance
        .collection('account')
        .doc(user.email)
        .update({'isVerified': true});
    
    print('Correo verificado');
  }
}
}

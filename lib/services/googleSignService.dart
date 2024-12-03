import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class GoogleSignInService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Iniciar sesión con Google
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Si el usuario cancela el inicio de sesión
        return;
      }

      // Obtener el GoogleSignInAuthentication para obtener los tokens
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear una credencial de Firebase usando el token de Google
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión con la credencial de Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Obtener los detalles de la cuenta de Google
      User? user = userCredential.user;
      if (user != null) {
        String userId = user.uid;
        String userName = googleUser.displayName ?? 'Desconocido';
        String userEmail = googleUser.email;
        String userProfileImage = googleUser.photoUrl ??
            'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/default-avatar.png';

        // Guardar la información del usuario en Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'user': userName,
          'profileImage': userProfileImage,
        });

        // Guardar el correo electrónico y el estado de onboarding en otra colección
        await FirebaseFirestore.instance.collection('account').doc(userEmail).set({
          'email': userEmail,
          'onboarding': false, // Aquí puedes definir si el onboarding está completado o no
        });

        // Si quieres redirigir a otra pantalla después de guardar la información
        Navigator.pushReplacementNamed(context, '/home'); // Ejemplo de navegación
      }
    } catch (e) {
      print('Error al iniciar sesión con Google: $e');
      // Puedes mostrar un mensaje de error al usuario si lo deseas
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al iniciar sesión con Google. Inténtalo nuevamente.'),
      ));
    }
  }
}

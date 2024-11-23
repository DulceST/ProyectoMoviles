import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Creacion de la cuenta 
  /*Future createAcount(String email, String password, String user, String phone, String country, String state, String city)async{
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential.user);
      
      String userId = userCredential.user?.uid ?? ''; // Obtener el UID del usuario recién creado

      // Verificar si el UID es válido antes de proceder
    if (userId.isNotEmpty) {
      // Crear un documento en Firestore con la información del usuario
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'user': user,
        'email': email,
        'password': password,
        'phone': phone,
        'country': country,
        'state': state,
        'city': city,
        
      });
      return userId; 
    }else{
       return null;
    }    
    } on FirebaseAuthException catch (e) {
      //password debil 
      if(e.code == 'weak-password'){
        print('Contraseña es debil');
        return 1; //si manda 1 es debil 
      }else if(e.code == 'email-already-in-use'){//email ya este en uso 
      print('El correo ya esta en uso ');
      return 2; 
      }//si no es ninguno de esos errores
    }catch(e){
      print(e);//manda el error 
    }
  }*/

  Future createAcount(String email, String password)async{
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential.user);
      
       // Obtener el UID del usuario recién creado
 
    } on FirebaseAuthException catch (e) {
      //password debil 
      if(e.code == 'weak-password'){
        print('Contraseña es debil');
        return 1; //si manda 1 es debil 
      }else if(e.code == 'email-already-in-use'){//email ya este en uso 
      print('El correo ya esta en uso ');
      return 2; 
      }//si no es ninguno de esos errores
    }catch(e){
      print(e);//manda el error 
    }
  }

  Future<bool> isNewUser(String email) async {
  // Aquí puedes verificar en tu base de datos si el usuario ya ha completado el onboarding
  // Por ejemplo, comprobando si existe un campo en la base de datos que indique si es un nuevo usuario.
  var userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
  return !userDoc.exists;  // Si el documento no existe, es un usuario nuevo
}


  Future singInEmailAndPassword(String email, String password)async{
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final a = userCredential.user;//obtiene el usuario 
      //si el usuario es distinto de nulo retorna el id
      if(a?.uid != null){
        return 0; 
      }
    } on FirebaseAuthException catch (e) {
      if(e.code=='user-not-found'){
        return 1; 
      }else if(e.code=='wrong-password'){
        return 2; 
      }  
    }
      return 3; 
  }

}
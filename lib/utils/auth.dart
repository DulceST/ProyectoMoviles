import 'package:firebase_auth/firebase_auth.dart';

class AuthServices{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Creacion de la cuenta 
  Future createAcount(String email, String password)async{
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential.user);
      return(userCredential.user?.uid);//el uid es el id del usuario 
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

  Future singInEmailAndPassword(String email, String password)async{
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final a = userCredential.user;//obtiene el usuario 
      //si el usuario es distinto de nulo retorna el id
      if(a?.uid != null){
        return a?.uid;
      }
    } on FirebaseAuthException catch (e) {
      if(e.code=='user-not-found'){
        return 1; 
      }else if(e.code=='wrong-password'){
        return 2; 
      }  
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices{
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future createAcount(String email, String password)async{
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential);
      await FirebaseFirestore.instance.collection('account').doc(email).set({
      'onboarding': false, 
      'email': email,      
    });
      
    } on FirebaseAuthException catch (e) {
      if(e.code == 'weak-password'){
        return 1; //1 es contraseña debil
      }else if(e.code == 'email-already-in-use'){
      return 2; //2 el correo ya esta en uso
      }
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
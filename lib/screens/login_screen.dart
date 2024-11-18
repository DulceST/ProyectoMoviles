import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proyecto_moviles/utils/auth.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
  
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final AuthServices _auth = AuthServices();
  
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}


@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image.asset('assets/earth_logo.png', height: 150),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Lógica para recuperar la contraseña
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Registrar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                _formKey.currentState?.save();
                if(_formKey.currentState?.validate()==true){
                  final v = _formKey.currentState?.value;
                  var result = await _auth.singInEmailAndPassword(v?['username'], v?['password']);
                  if(result == 1){
                    showSnackBar(context, 'Usuario o contraseña equivocados');
                  }else if(result == 2){
                    showSnackBar(context, 'Usuario o contraseña equivocados');
                  }else if(result != null){
                    Navigator.popAndPushNamed(context, '/home');
                  } 
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 30),
            const Text('O inicia sesión con'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón de Google
                IconButton(
                  onPressed: () {
                    // Lógica para autenticarse con Google
                  },
                  icon: const FaIcon(FontAwesomeIcons.google),
                  iconSize: 40,
                ),
                const SizedBox(width: 20),
                // Botón de Facebook
                IconButton(
                  onPressed: () {
                    // Lógica para autenticarse con Facebook
                  },
                  icon: const FaIcon(FontAwesomeIcons.facebook),
                  iconSize: 40,
                ),
                const SizedBox(width: 20),
                // Botón de GitHub
                IconButton(
                  onPressed: () {
                    // Lógica para autenticarse con GitHub
                  },
                  icon: const FaIcon(FontAwesomeIcons.github),
                  iconSize: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proyecto_moviles/utils/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Usamos un GlobalKey de FormState
  final AuthServices _auth = AuthServices();
  final _emailController = TextEditingController();
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
        child: Form(
          key: _formKey, // Asociamos el Form al GlobalKey
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El email es obligatorio';
                  }
                  // Validar si es un email válido
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!regex.hasMatch(value)) {
                    return 'Ingresa un email válido';
                  }
                  return null; // Si es válido, retornamos null
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  return null; // Si es válido, retornamos null
                },
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String email = '';
                          String password = '';
                          return AlertDialog(
                            title: const Text('Registro'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Correo electrónico',
                                  ),
                                  onChanged: (value) {
                                    email = value;
                                  },
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Contraseña',
                                  ),
                                  obscureText: true,
                                  onChanged: (value) {
                                    password = value;
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Cerrar el diálogo
                                },
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Llamar al método para crear cuenta
                                  int? result =
                                      await _auth.createAcount(email, password);
                                  if (result == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Cuenta creada exitosamente'),
                                        backgroundColor: Colors
                                            .green, // Color verde para éxito
                                      ),
                                    );
                                  } else if (result == 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('La contraseña es débil.'),
                                        backgroundColor:
                                            Colors.red, // Color rojo para error
                                      ),
                                    );
                                  } else if (result == 2) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('El correo ya está en uso.'),
                                        backgroundColor:
                                            Colors.red, // Color rojo para error
                                      ),
                                    );
                                  }
                                  Navigator.of(context)
                                      .pop(); // Cerrar el diálogo
                                },
                                child: const Text('Registrar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Registrar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    final email = _emailController.text;
                    final password = _passwordController.text;

                    // Llamamos al método de autenticación
                    var result =
                        await _auth.singInEmailAndPassword(email, password);
                    print('Resultado del login: $result');

                    if (result == 1 || result == 2) {
                      showSnackBar(context, 'Usuario o contraseña equivocados');
                      _emailController.clear();
                      _passwordController.clear();
                    } else if (result == 0) {
                      Navigator.pushReplacementNamed(context, '/home');
                      _emailController.clear();
                      _passwordController.clear();
                      
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
                    icon: const Icon(Icons.facebook),
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
      ),
    );
  }
}

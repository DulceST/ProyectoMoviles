import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proyecto_moviles/utils/email_auth.dart';

class LoginpScreen extends StatefulWidget {
  const LoginpScreen({super.key});

  @override
  State<LoginpScreen> createState() => _LoginpScreenState();
}

class _LoginpScreenState extends State<LoginpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  int failedAttempts = 0;

  @override
  void dispose() {
    // Asegúrate de limpiar los controladores al destruir el widget
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Método para mostrar el SnackBar
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Método para mostrar el diálogo de verificación
  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verificación de correo'),
          content: const Text(
              'No has verificado tu correo. ¿Quieres que te reenviemos el correo de verificación?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  // Método para reenviar el correo de verificación
  Future<void> _resendVerificationEmail() async {
    // Obtener el usuario actual
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      try {
        // Actualizar el estado del usuario antes de enviar el correo
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        // Reenviar el correo de verificación
        await user?.sendEmailVerification();
        _showSnackBar(
            'Correo de verificación enviado. Revisa tu bandeja de entrada.');
      } catch (e) {
        // Manejar errores específicos
        if (e.toString().contains("TOO_MANY_REQUESTS")) {
          _showSnackBar(
              'Has intentado reenviar el correo demasiadas veces. Intenta nuevamente más tarde.');
        } else {      
          _showSnackBar(
              'Has intentado reenviar el correo demasiadas veces. Intenta nuevamente más tarde.');
        }
      }
    } else {
      _showSnackBar(
          'Tu correo ya está verificado o no hay un usuario autenticado.');
    }
  }

  // Función para validar el estado de onboarding
  Future<void> _validateOnboardingStatus(String email) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('account')
          .doc(email.toLowerCase()) // Asegúrate de normalizar el correo
          .get();

      if (userDoc.exists) {
        bool onboardingCompleted = userDoc.get('onboarding') ?? false;

        // Navegar dependiendo del estado de onboarding
        Navigator.pushReplacementNamed(
          context,
          onboardingCompleted ? '/home' : '/onboarding',
        );
      } else {
        _showSnackBar('Error al validar el estado de la cuenta.');
      }
    } catch (e) {
      print('Error al consultar Firestore: $e');
      _showSnackBar('Error al consultar el estado del usuario.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLandscape = constraints.maxWidth > 600;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                child: isLandscape
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Image.asset(
                                'assets/planta.png',
                                height: 160,
                                width: 160,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: _buildFormContent(),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 100),
                          Image.asset(
                            'assets/planta.png',
                            height: 150,
                            width: 150,
                          ),
                          const SizedBox(height: 20),
                          _buildFormContent(),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Correo electrónico'),
        ),
        TextField(
          controller: _passwordController,
          obscureText:
              _obscurePassword, // Usa el estado de la variable _obscurePassword
          decoration: InputDecoration(
            labelText: 'Contraseña',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword =
                      !_obscurePassword; // Cambia el estado al presionar el ícono
                });
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController _emailController =
                        TextEditingController();
                    TextEditingController _passwordController =
                        TextEditingController();

                    return AlertDialog(
                      title: const Text('Registrar'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                                labelText: 'Correo electrónico'),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _passwordController,
                            decoration:
                                const InputDecoration(labelText: 'Contraseña'),
                            obscureText: true,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Cerrar el diálogo
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            String email = _emailController.text;
                            String password = _passwordController.text;

                            if (email.isEmpty) {
                              _showSnackBar('El correo es obligatorio');
                              return;
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(email)) {
                              _showSnackBar(
                                  'Por favor ingresa un correo válido');
                              return;
                            }
                            if (password.isEmpty) {
                              _showSnackBar('La contraseña es obligatoria');
                              return;
                            }

                            int? result = await EmailAuth()
                                .createAccount(email, password, context);

                            if (result == 0) {
                              // Ingreso exitoso, verificar si el correo está validado
                              User? user = FirebaseAuth.instance.currentUser;

                              if (user != null) {
                                // Actualizar el estado del usuario
                                await user.reload();
                                user = FirebaseAuth.instance.currentUser;

                                if (user != null && user.emailVerified) {
                                  // Si el correo está verificado, proceder con el inicio de sesión
                                  await _validateOnboardingStatus(email);
                                } else {
                                  // Si el correo no está verificado
                                  await _resendVerificationEmail();
                                  _showSnackBar(
                                      'Por favor verifica tu correo electrónico antes de iniciar sesión.');
                                }
                              }
                            }

                            Navigator.pop(
                                context); // Cerrar el diálogo después de validación
                          },
                          child: const Text('Registrar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                'Registrar',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading
              ? null // Deshabilitar el botón mientras está cargando
              : () async {
                  if (_emailController.text.isEmpty) {
                    _showSnackBar('El correo es obligatorio');
                    return;
                  }

                  final email = _emailController.text;
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                    _showSnackBar('Por favor ingresa un correo válido');
                    return;
                  }

                  if (_passwordController.text.isEmpty) {
                    _showSnackBar('La contraseña es obligatoria');
                    return;
                  }

                  String password = _passwordController.text;

                  // Iniciar el proceso de carga
                  setState(() {
                    isLoading = true;
                  });

                  // Llamamos al método de inicio de sesión
                  int? result = await EmailAuth().signIn(email, password);

                  // Detener el indicador de carga
                  setState(() {
                    isLoading = false;
                  });

                  // Comprobamos el resultado de la autenticación
                  if (result == 0) {
                    // Ingreso exitoso, verificar si el correo está validado
                    User? user = FirebaseAuth.instance.currentUser;

                    if (user != null && user.emailVerified) {
                      // Si el correo está verificado, proceder con el inicio de sesión
                      await _validateOnboardingStatus(email);
                    } else {
                      // Si el correo no está verificado, mostrar un mensaje y no permitir el inicio de sesión
                      await _resendVerificationEmail();
                    }
                  } else if (result == 4) {
                    _showSnackBar(
                        'Datos de usuario incorrectos, vuelve a intentarlo');
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          ),
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white) // Mostrar el indicador de carga
              : const Text(
                  'Iniciar sesión',
                  style: TextStyle(color: Colors.white),
                ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text('O inicia sesión con'),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {},
              icon: const FaIcon(FontAwesomeIcons.google),
              iconSize: 40,
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.facebook),
              iconSize: 40,
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () {},
              icon: const FaIcon(FontAwesomeIcons.github),
              iconSize: 40,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    bool obscureText = false,
  }) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

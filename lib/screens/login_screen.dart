import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proyecto_moviles/utils/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthServices _auth = AuthServices();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Método para mostrar un SnackBar
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Método para mostrar el cuadro de diálogo de registro
  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String email = '';
        String password = '';
        return AlertDialog(
          title: const Text('Registro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                label: 'Correo electrónico',
                onChanged: (value) => email = value,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: 'Contraseña',
                obscureText: true,
                onChanged: (value) => password = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _handleRegister(email, password);
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  // Lógica para manejar el registro de usuarios
  Future<void> _handleRegister(String email, String password) async {
    int? result = await _auth.createAcount(email, password, context);
    if (result == null) {
      _showSnackBar(
        'Cuenta creada exitosamente, Se ha enviado un correo de verificación.',
        backgroundColor: Colors.green,
      );
    } else if (result == 1) {
      _showSnackBar('La contraseña es débil.');
    } else if (result == 2) {
      _showSnackBar('El correo ya está en uso.');
      _clearControllers();
    }
  }

  // Lógica para iniciar sesión
  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() == true) {
      final email = _emailController.text;
      final password = _passwordController.text;

      var result = await _auth.singInEmailAndPassword(email, password);

      if (result == 1 || result == 2) {
        _showSnackBar('Usuario o contraseña equivocados');
        _clearControllers();
      } else if (result == 0) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('account')
            .doc(email)
            .get();
        if (userDoc.exists && userDoc['isVerified'] == true) {
          await _validateOnboardingStatus(email);
        } else {
          _showSnackBar('Correo no verificado. Por favor verifica tu correo.');
          _clearControllers();
        }
      }
    }
  }

  void _showLoadingGif() {
    showDialog(
      context: context,
      barrierDismissible: false, // El usuario no puede cerrar el GIF
      builder: (context) {
        return Center(
          child: Image.asset(
            'assets/cargando.gif', // Ruta de la imagen en los assets
            height: 100,
            width: 100,
          ),
        );
      },
    );
  }

  // Validar el estado del onboarding del usuario
  Future<void> _validateOnboardingStatus(String email) async {
    try {
      _showLoadingGif();
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('account')
          .doc(email)
          .get();

      if (userDoc.exists) {
        bool onboardingCompleted = userDoc.get('onboarding') ?? false;
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
    } finally {
      _clearControllers();
    }
  }

  // Limpiar los controladores
  void _clearControllers() {
    _emailController.clear();
    _passwordController.clear();
  }

  // Método para construir un TextFormField
  Widget _buildTextField({
    required String label,
    bool obscureText = false,
    void Function(String)? onChanged,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label es obligatorio';
        }
        if (label == 'Correo electrónico') {
          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!regex.hasMatch(value)) {
            return 'Ingresa un email válido';
          }
        }
        return null;
      },
    );
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
                key: _formKey,
                child: isLandscape
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo a la izquierda
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
                          // Formulario a la derecha
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

// Método para construir el contenido del formulario
  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          label: 'Email',
          controller: _emailController,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Contraseña',
          controller: _passwordController,
          obscureText: true,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                // Lógica para recuperar la contraseña
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: _showRegisterDialog,
              child: const Text(
                'Registrar',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 15,
            ),
          ),
          child: const Text(
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
              onPressed: () {
                // Lógica para autenticarse con Google
              },
              icon: const FaIcon(FontAwesomeIcons.google),
              iconSize: 40,
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () {
                // Lógica para autenticarse con Facebook
              },
              icon: const Icon(Icons.facebook),
              iconSize: 40,
            ),
            const SizedBox(width: 20),
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
    );
  }
}

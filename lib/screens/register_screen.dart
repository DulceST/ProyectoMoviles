import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles/utils/auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCountry;
  String? selectedState; 
  String? selectedCity;

  // Controladores para los campos
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final AuthServices _authServices = AuthServices();

  // Método para manejar el registro
  void _register() async {
    if (_formKey.currentState?.validate() == true) {
      String user = _userController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String phone = _phoneController.text;

      if (selectedCountry == null || selectedState == null || selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona país, estado y ciudad')),
        );
        return;
      }

      // Llamar al método de creación de cuenta
      var result = await _authServices.createAcount(
        email,
        password,
        user,
        phone,
        selectedCountry!, 
        selectedState!,
        selectedCity!,
      );

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la cuenta')),
        );
      } else if (result == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña débil')),
        );
      } else if (result == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El correo ya está en uso')),
        );
      }else{

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado exitosamente')),
        );

        // Limpiar los campos del formulario
        _userController.clear();
        _emailController.clear();
        _passwordController.clear();
        _phoneController.clear();
        
        // Redirigir al login
        Navigator.popAndPushNamed(context, '/login');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navega de vuelta a la pantalla de login
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Regístrate',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _userController,
                  label: 'Usuario',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _emailController,
                  label: 'Correo',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa un número de teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                CSCPicker(
                  showStates: true,
                  showCities: true,
                  onCountryChanged: (value) {
                    setState(() {
                      selectedCountry = value;
                      selectedState = null;
                      selectedCity = null;
                    });
                  },
                  onStateChanged: (value) {
                    setState(() {
                      selectedState = value;
                      selectedCity = null;
                    });
                  },
                  onCityChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  }, // ciudad seleccionada
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

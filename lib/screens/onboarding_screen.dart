import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_moviles/models/content_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  late PageController _controller;
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _phoneController = TextEditingController();
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  Map<String, bool> materialPreferences = {
    "Plástico": false,
    "Papel": false,
    "Vidrio": false,
    "Metal": false,
  };
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _userController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<String?> _uploadImageToSupabase(XFile imageFile) async {
    try {
      final supabaseClient = Supabase.instance.client;
      final storage = supabaseClient.storage.from('profile-images');

      final fileName = path.basename(imageFile.path);
      final filePath = 'profile-images/$fileName';
      final file = File(imageFile.path);

      final response = await storage.upload(filePath, file);

      // Verificar si hubo un error en la carga
      if (response.error != null) {
        print('Error al subir la imagen: ${response.error?.message}');
        return null;
      }

      // Si la carga fue exitosa, imprimir la respuesta
      print('Archivo subido correctamente:');

      // Obtener la URL pública
      final imageUrl = storage.getPublicUrl(filePath);
      print('URL de la imagen: $imageUrl');

      return imageUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  Future<void> _completeOnboarding(String uid) async {
    if (_formKey.currentState!.validate()) {
      // Recopilamos los materiales seleccionados
      List<String> selectedMaterials = materialPreferences.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      try {
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImageToSupabase(_imageFile!);
        }

        // Registrar datos en la colección 'users'
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'user': _userController.text.trim(),
          'phone': _phoneController.text.trim(),
          'materials': selectedMaterials,
          'profileImage': imageUrl ??
              'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/profile-images/profile-images/images.jpg' // Guardar la ruta local
        });

        final email = FirebaseAuth.instance.currentUser?.email;

        // Actualizar el estado de onboarding a true en la colección 'account' usando el email
        await FirebaseFirestore.instance
            .collection('account')
            .doc(email)
            .update({
          'onboarding': true,
        });

        // Guardar localmente el estado del onboarding como completado
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding', true);

        // Navegar al Home
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        // Manejo de errores
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar usuario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      // Pantalla 1: Bienvenida
                      if (i == 0)
                        Column(
                          children: [
                            if (contents[i].lottie != null)
                              const SizedBox(height: 60),
                            Lottie.asset(
                              contents[i].lottie!,
                              height: 260,
                            ),
                            Text(
                              contents[i].title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              contents[i].description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                      // Pantalla 2: Encuentra puntos de reciclaje
                      if (i == 1)
                        Column(
                          children: [
                            if (contents[i].lottie != null)
                              const SizedBox(height: 80),
                            Lottie.asset(
                              contents[i].lottie!,
                              height: 200,
                            ),
                            Text(
                              contents[i].title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              contents[i].description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            // Preferencias de materiales
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  materialPreferences.keys.map((material) {
                                return CheckboxListTile(
                                  title: Text(material),
                                  value: materialPreferences[material],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      materialPreferences[material] =
                                          value ?? false;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                      // Pantalla 3: Registro de usuario
                      if (i == 2)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 80),
                                  Lottie.asset(
                                    contents[i].lottie!,
                                    height: 130,
                                  ),
                                  Text(
                                    contents[i].title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    contents[i].description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  // Formulario de registro
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _userController,
                                          decoration: const InputDecoration(
                                            labelText: "Nombre de usuario",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 15),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Por favor, ingresa tu nombre de usuario";
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: _phoneController,
                                          decoration: const InputDecoration(
                                            labelText: "Teléfono",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 15),
                                          ),
                                          keyboardType: TextInputType.phone,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Por favor, ingresa tu número de teléfono";
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 15),

                                        // Seleccionar imagen
                                        ElevatedButton(
                                          onPressed: _pickImage,
                                          child: const Text(
                                              'Seleccionar imagen',
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        ),
                                        if (_imageFile != null)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.file(
                                              File(_imageFile!.path),
                                              height: 100,
                                              width: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        const SizedBox(height: 15),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navegación entre pantallas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
                child: const Text("Anterior",
                    style: TextStyle(color: Colors.green)),
              ),
              Row(
                children: List.generate(
                  contents.length,
                  (index) => Container(
                    margin: const EdgeInsets.all(1),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == index
                          ? Colors.green
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (currentIndex == contents.length - 1) {
                    _completeOnboarding(FirebaseAuth.instance.currentUser!.uid);
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
                child: Text(
                    currentIndex == contents.length - 1
                        ? "Completar"
                        : "Siguiente",
                    style: const TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on String {
  get error => null;
}

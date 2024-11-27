import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_moviles/models/content_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> _completeOnboarding(String uid) async {
    if (_formKey.currentState!.validate()) {
      // Recopilamos los materiales seleccionados
      List<String> selectedMaterials = materialPreferences.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      try {
        // Obtener el email del usuario autenticado
        String? email = FirebaseAuth.instance.currentUser?.email;
        String? imageUrl;
        String? uid = FirebaseAuth.instance.currentUser?.uid;


        if (uid == null) {
          throw Exception('Usuario no autenticado');
        }

        // Subir imagen si fue seleccionada
        if (_imageFile != null) {
          final fileBytes = await _imageFile!.readAsBytes();

          // Crear la ruta del archivo, incluyendo el uid en el bucket 'users'
          final fileName =
              'users/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

          // Subir a Supabase Storage
          final supabaseStorage =
              Supabase.instance.client.storage.from('users');
          final uploadResponse = await supabaseStorage.uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(
                upsert: true), // Sobrescribe si el archivo existe
          );

          if (uploadResponse.error != null) {
            throw Exception(
                'Error al subir la imagen: ${uploadResponse.error!.message}');
          }

          // Obtener la URL pública de la imagen (opcional, según tu configuración)
          imageUrl = supabaseStorage.getPublicUrl(fileName);
        } else {
          // Si no se sube ninguna imagen, asignar una imagen por defecto
          imageUrl =
              'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/default-avatar.png';
        }

        // Registrar datos en la colección 'users'
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'user': _userController.text.trim(),
          'phone': _phoneController.text.trim(),
          'country': selectedCountry,
          'state': selectedState,
          'city': selectedCity,
          'materials': selectedMaterials,
          'profileImage': imageUrl,
        });

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
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index; // Actualiza el índice actual
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      if (contents[i].lottie != null)
                        Lottie.network(
                          contents[i].lottie!,
                          height: 300,
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
                      // Agregar checkboxes solo en una pestaña específica
                      if (i == 1) // Aquí defines el índice de la pestaña
                        Expanded(
                          child: ListView(
                            children: materialPreferences.keys.map((material) {
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
                        ),
                      // Formulario para datos del usuario en la última pestaña
                      if (i == 2)
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _userController,
                                  decoration: const InputDecoration(
                                      labelText: "Usuario",
                                      prefixIcon: Icon(Icons.person)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu nombre';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: "Teléfono",
                                    prefixIcon: Icon(Icons.phone),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu teléfono';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
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
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Mostrar la imagen seleccionada o predeterminada
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: _imageFile != null
                                        ? FileImage(File(_imageFile!.path))
                                        : const NetworkImage(
                                            'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/default-avatar.png'), // Imagen predeterminada
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Dots de la página
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              contents.length,
              (index) => buildDot(index, context),
            ),
          ),
          // Botón para navegar entre pantallas
          Container(
            height: 40,
            margin: const EdgeInsets.all(40),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (currentIndex == contents.length - 1) {
                  String uid = FirebaseAuth.instance.currentUser!.uid;

                  _completeOnboarding(
                      uid); // Completar onboarding en la última página
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                currentIndex == contents.length - 1 ? "Registrar" : "Next",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir los dots
  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

extension on String {
  get error => null;
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProfileDialog extends StatefulWidget {
  final String? initialName;
  final String? initialPhone;
  final String? initialImage;
  final VoidCallback? onProfileUpdated;

  const UpdateProfileDialog({
    super.key,
    this.initialName,
    this.initialPhone,
    this.initialImage,
    this.onProfileUpdated,
  });

  @override
  _UpdateProfileDialogState createState() => _UpdateProfileDialogState();
}

class _UpdateProfileDialogState extends State<UpdateProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  
  get path => null;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _phoneController.text = widget.initialPhone ?? '';
  }
Future<void> _pickImage() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _imageFile = pickedFile;
    });
  } else {
    // Si no se selecciona una imagen, mostrar mensaje
    print('No se ha seleccionado ninguna imagen');
  }
}

  Future<String?> _uploadImageToSupabase(XFile imageFile) async {
  try {
    final supabaseClient = Supabase.instance.client;
    final storage = supabaseClient.storage.from('profile-images');

    // Verificar que imageFile y su ruta no sean nulos
    if (imageFile.path.isEmpty) {
      print('El archivo de imagen es inválido');
      return null;
    }

    // Obtener el nombre del archivo
    final fileName = path.basename(imageFile.path);
    if (fileName.isEmpty) {
      print('El nombre del archivo no es válido');
      return null;
    }

    final filePath = 'profile-images/$fileName';
    final file = File(imageFile.path);

    // Subir el archivo a Supabase
    final response = await storage.upload(filePath, file);

    if (response.error != null) {
      print('Error al subir la imagen: ${response.error?.message}');
      return null;
    }

    // Obtener la URL pública de la imagen cargada
    final imageUrl = storage.getPublicUrl(filePath).data;
    print('URL de la imagen: $imageUrl');

    return imageUrl;
  } catch (e) {
    print('Error al subir la imagen: $e');
    return null;
  }
}



  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          throw Exception('Usuario no autenticado');
        }

        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImageToSupabase(_imageFile!);
        }

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'user': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'profileImage': imageUrl ?? widget.initialImage,
        });

        if (widget.onProfileUpdated != null) {
          widget.onProfileUpdated!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        Navigator.of(context).pop();
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Actualizar Perfil'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'El teléfono es obligatorio' : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Seleccionar foto'),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(
                    File(_imageFile!.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _updateUserData,
          child: const Text('Actualizar'),
        ),
      ],
    );
  }
}

extension on String {
  get error => null;
  
  get data => null;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


class ReciclajeScreen extends StatefulWidget {
  const ReciclajeScreen({super.key});

  @override
  _ReciclajeScreenState createState() => _ReciclajeScreenState();
}

class _ReciclajeScreenState extends State<ReciclajeScreen> {
  final _materialController = TextEditingController();
  final _cantidadController = TextEditingController();

  final CollectionReference _reciclajesCollection =
      FirebaseFirestore.instance.collection('reciclajes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Reciclaje'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _materialController,
              decoration: const InputDecoration(labelText: 'Material reciclado'),
            ),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Guardar datos y generar notificación
                _guardarReciclaje();
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }

  void _guardarReciclaje() async {
    // Obtener los datos del material y cantidad
    final material = _materialController.text;
    final cantidad = int.tryParse(_cantidadController.text) ?? 0;

    if (material.isNotEmpty && cantidad > 0) {
      // Guardar datos de reciclaje en Firestore
      try {
        await _reciclajesCollection.add({
          'material': material,
          'cantidad': cantidad,
          'fecha': FieldValue.serverTimestamp(),
        });

        // Enviar notificación de recordatorio al usuario
        _enviarNotificacion(material, cantidad);

        // Limpiar los campos después de guardar
        _materialController.clear();
        _cantidadController.clear();
      } catch (e) {
        print("Error al guardar reciclaje: $e");
      }
    } else {
      print("Por favor ingresa un material y cantidad válidos.");
    }
  }

  // Función para enviar una notificación de recordatorio al usuario
  void _enviarNotificacion(String material, int cantidad) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic('reciclaje'); 
    print('Notificación de reciclaje enviada para $cantidad $material');
  }
}

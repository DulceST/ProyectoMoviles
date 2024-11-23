import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geocoding/geocoding.dart'; // Importa el paquete de geocodificación
import 'package:proyecto_moviles/firebase/database_location.dart';
import 'dart:async';

import 'package:proyecto_moviles/models/recycling_location.dart';

class AddLocationScreen extends StatefulWidget {
  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _selectedLocation;
  final Set<Marker> _markers = {};

  // Inicializa la posición del mapa
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-34.6037, -58.3816), // Cambia a la posición inicial deseada
    zoom: 12,
  );

  // Método para obtener la dirección usando geocodificación inversa
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street}, ${place.locality}, ${place.country}';
        setState(() {
          _addressController.text = address;
        });
      }
    } catch (e) {
      print("Error al obtener la dirección: $e");
    }
  }

  // Método que se llama al hacer tap en el mapa
  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId("selected-location"),
          position: position,
        ),
      );
    });

    // Llama a la función para obtener la dirección y llenar el campo
    _getAddressFromLatLng(position);
  }

 Future<void> _saveLocation() async {
  if (_selectedLocation != null && _nameController.text.isNotEmpty) {
    final locationData = RecyclingLocation(
      name: _nameController.text,
      address: _addressController.text,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude, id: '', acceptedMaterials: [],
    );

    try {
      // Create an instance of DatabaseLocation to access Firestore
      final databaseLocation = DatabaseLocation();
      // Add the recycling location to Firestore
      await databaseLocation.addRecyclingLocation(locationData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ubicación guardada exitosamente')),
      );

      // Clear the fields after saving
      _nameController.clear();
      _addressController.clear();
      setState(() {
        _selectedLocation = null;
        _markers.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la ubicación: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor, selecciona una ubicación y llena los campos requeridos')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Lugar de Reciclaje')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              onTap: _onMapTap,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del lugar',
                  ),
                ),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                  ),
                  readOnly: true, // Hace que el campo de dirección sea de solo lectura
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveLocation,
                  child: Text('Guardar ubicación'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

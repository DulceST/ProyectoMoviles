import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMarkers();
  }

  // Método para obtener la ubicación actual del usuario
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El servicio de ubicación está deshabilitado. Habilítalo para continuar.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Los permisos de ubicación fueron denegados.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Los permisos de ubicación están permanentemente denegados.')),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 15),
    ));
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: MarkerId("current-location"),
          position: _selectedLocation!,
        ),
      );
      _getAddressFromLatLng(_selectedLocation!);
    });
  }

  // Método para obtener los marcadores desde la base de datos
  Future<void> _loadMarkers() async {
    final databaseLocation = DatabaseLocation();
    final locations = await databaseLocation.getRecyclingLocations();
    setState(() {
      for (var location in locations) {
        _markers.add(
          Marker(
            markerId: MarkerId(location.id),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: location.name,
              snippet: location.address,
            ),
          ),
        );
      }
    });
  }

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
      longitude: _selectedLocation!.longitude,
      id: '',
      acceptedMaterials: [],
    );

    try {
      // Create an instance of DatabaseLocation to access Firestore
      final databaseLocation = DatabaseLocation();
      // Add the recycling location to Firestore
      await databaseLocation.addRecyclingLocation(locationData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ubicación guardada exitosamente')),
      );

      // Regresa a la pantalla anterior después de guardar
      Navigator.pop(context);
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
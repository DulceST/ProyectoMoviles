import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  late GoogleMapController _mapController;

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception("Los servicios de localización están desactivados.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Permisos de localización denegados.");
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return LatLng(position.latitude, position.longitude);
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _pickedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona una ubicación'),
      ),
      body: FutureBuilder<LatLng>(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          LatLng initialLocation = snapshot.data!;
          return GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: 14,
            ),
            markers: _pickedLocation != null
                ? {
                    Marker(
                      markerId: MarkerId('pickedLocation'),
                      position: _pickedLocation!,
                    ),
                  }
                : {},
            onTap: _onMapTapped,
          );
        },
      ),
      floatingActionButton: _pickedLocation != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context, _pickedLocation);
              },
              label: Text('Confirmar'),
              icon: Icon(Icons.check),
            )
          : null,
    );
  }
}

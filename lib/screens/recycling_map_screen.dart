import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_moviles/models/recycling_location.dart';

class RecyclingMapScreen extends StatefulWidget {
  const RecyclingMapScreen({super.key});

  @override
  _RecyclingMapScreenState createState() => _RecyclingMapScreenState();
}

class _RecyclingMapScreenState extends State<RecyclingMapScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  bool showMap = true; // Variable para alternar entre mapa y lista
  late BitmapDescriptor eventIcon;

  @override
  void initState() {
    super.initState();
    loadCustomIcons();
    fetchRecyclingLocations();
    fetchActiveEvents();
  }

  Future<void> loadCustomIcons() async {
    eventIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(20, 20)),
      'assets/green_pin.png', // Ruta del ícono personalizado
    );
  }

  Future<void> fetchRecyclingLocations() async {
    FirebaseFirestore.instance.collection('recycling_locations').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final recyclingLocation = RecyclingLocation.fromMap(data);

        markers.add(
          Marker(
            markerId: MarkerId(recyclingLocation.id),
            position: LatLng(recyclingLocation.latitude, recyclingLocation.longitude),
            infoWindow: InfoWindow(
              title: recyclingLocation.name,
              snippet: recyclingLocation.address,
              onTap: () => showCreatorInfo(recyclingLocation.id),
            ),
          ),
        );
      }
      setState(() {});
    });
  }

  Future<void> fetchActiveEvents() async {
    FirebaseFirestore.instance.collection('recycling_events').get().then((snapshot) {
      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final startDate = (data['start_date'] as Timestamp).toDate();
        final durationDays = data['duration_days'] ?? 0;
        final endDate = startDate.add(Duration(days: durationDays));

        if (now.isAfter(startDate) && now.isBefore(endDate)) {
          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(data['location']['latitude'], data['location']['longitude']),
              infoWindow: InfoWindow(
                title: data['name'],
                snippet: 'Evento Activo\n${data['description']}',
                onTap: () => showEventDetails(doc.id, data),
              ),
              icon: eventIcon,
            ),
          );
        }
      }
      setState(() {});
    });
  }

  void showCreatorInfo(String id) async {
    final doc = await FirebaseFirestore.instance.collection('recycling_locations').doc(id).get();
    final creator = doc.data()?['creator'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del punto'),
        content: Text('Creado por: $creator\nDirección: ${doc.data()?['address']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void showEventDetails(String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['name']),
        content: Text(
          'Descripción: ${data['description']}\n\n'
          'Duración: ${data['duration_days']} días\n'
          'Fecha de inicio: ${(data['start_date'] as Timestamp).toDate().toLocal()}'.split(' ')[0],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntos de Reciclaje'),
        actions: [
          IconButton(
            icon: Icon(showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                showMap = !showMap; // Alterna entre mapa y lista
              });
            },
          ),
        ],
      ),
      body: showMap
          ? GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: const CameraPosition(
                target: LatLng(19.432608, -99.133209), // Ubicación inicial
                zoom: 12,
              ),
              markers: markers,
            )
          : ListView(
              children: markers.map((marker) {
                return ListTile(
                  title: Text(marker.infoWindow.title ?? ''),
                  subtitle: Text(marker.infoWindow.snippet ?? ''),
                  onTap: () => marker.infoWindow.onTap?.call(),
                );
              }).toList(),
            ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
          heroTag: null, // Desactiva el Hero implícito
          onPressed: () {
            Navigator.pushNamed(context, "/add_location");
          },
          tooltip: 'Agregar Ubicación',
          child: const Icon(Icons.add_location),
        ),
      ),
    );
  }
}
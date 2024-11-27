import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_moviles/models/recycling_location.dart';

class RecyclingMapScreen extends StatefulWidget {
  @override
  _RecyclingMapScreenState createState() => _RecyclingMapScreenState();
}

class _RecyclingMapScreenState extends State<RecyclingMapScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  bool showMap = true; // Variable para alternar entre mapa y lista

  @override
  void initState() {
    super.initState();
    fetchRecyclingLocations();
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

  void showCreatorInfo(String id) async {
    final doc = await FirebaseFirestore.instance.collection('recycling_locations').doc(id).get();
    final creator = doc.data()?['creator'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del punto'),
        content: Text('Creado por: $creator\nDirección: ${doc.data()?['address']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puntos de Reciclaje'),
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
            initialCameraPosition: CameraPosition(
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
                onTap: () => showCreatorInfo(marker.markerId.value),
              );
            }).toList(),
          ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, "/add_location");
          },
          tooltip: 'Add Location',
          child: Icon(Icons.add_location),
        ),
      ),
    );
  }
}
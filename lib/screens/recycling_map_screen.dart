import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_moviles/models/recycling_location.dart';
import 'package:proyecto_moviles/providers/theme_provider.dart';

class RecyclingMapScreen extends StatefulWidget {
  @override
  _RecyclingMapScreenState createState() => _RecyclingMapScreenState();
}

class _RecyclingMapScreenState extends State<RecyclingMapScreen> {
  late GoogleMapController mapController;
  Set<Marker> recyclingMarkers = {};  // Marcadores de reciclaje
  Set<Marker> eventMarkers = {};      // Marcadores de eventos

  bool showMap = true; // Variable para alternar entre mapa y lista
  late BitmapDescriptor eventIcon;
  LatLng? currentLocation;

@override
void initState() {
  super.initState();
  loadCustomIcons();
  setupFirestoreListeners();
  determinePosition();
}

void setupFirestoreListeners() {
  // Listener para puntos de reciclaje
  FirebaseFirestore.instance.collection('recycling_locations').snapshots().listen((snapshot) {
    Set<Marker> newRecyclingMarkers = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final recyclingLocation = RecyclingLocation.fromMap(data);

      newRecyclingMarkers.add(
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
    setState(() {
      recyclingMarkers = newRecyclingMarkers;
    });
  });

  // Listener para eventos de reciclaje
  FirebaseFirestore.instance.collection('recycling_events').snapshots().listen((snapshot) {
    final now = DateTime.now();
    Set<Marker> newEventMarkers = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final startDate = (data['start_date'] as Timestamp).toDate();
      final durationDays = data['duration_days'] ?? 0;
      final endDate = startDate.add(Duration(days: durationDays));

      if (now.isAfter(startDate) && now.isBefore(endDate)) {
        newEventMarkers.add(
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
    setState(() {
      eventMarkers = newEventMarkers;
    });
  });
}



  Future<void> loadCustomIcons() async {
    eventIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(20, 20)),
      'assets/green_pin.png', // Ruta del ícono personalizado
    );
  }

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // No se puede continuar sin el servicio habilitado
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permiso denegado, no se puede continuar
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permiso denegado permanentemente
      return;
    }

    // Obtiene la posición actual
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> fetchRecyclingLocations() async {
    FirebaseFirestore.instance.collection('recycling_locations').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final recyclingLocation = RecyclingLocation.fromMap(data);

        recyclingMarkers.add(
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
          eventMarkers.add(
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
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);

    // Combina ambos conjuntos de marcadores
    final combinedMarkers = {...recyclingMarkers, ...eventMarkers};

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
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : (showMap
              ? GoogleMap(
                  key: ValueKey(combinedMarkers.hashCode), // Usa el hashCode combinado de los marcadores
                  onMapCreated: (controller) => mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: currentLocation!,
                    zoom: 12,
                  ),
                  markers: combinedMarkers, // Usa los marcadores combinados
                )
              : Accordion(
                maxOpenSections: 1,
                headerBackgroundColor: themeProvider.primaryColor, // Color dinámico del encabezado
                contentBackgroundColor: themeProvider.cardColor, // Color dinámico del contenido
                headerPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                children: combinedMarkers.map((marker) {
                  return AccordionSection(
                    header: Text(
                      marker.infoWindow.title ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marker.infoWindow.snippet ?? '',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => marker.infoWindow.onTap?.call(),
                          child: Text('Ver detalles'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )),
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
class RecyclingLocation {
  String id;
  String name;
  String address;
  List<String> acceptedMaterials;
  double latitude;
  double longitude;

  RecyclingLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.acceptedMaterials,
    required this.latitude,
    required this.longitude,
  });

  // Convierte un objeto a un Map para guardar en Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'acceptedMaterials': acceptedMaterials,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Convierte un Map de Firebase a un objeto de tipo RecyclingLocation
  factory RecyclingLocation.fromMap(Map<String, dynamic> map) {
    return RecyclingLocation(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      acceptedMaterials: List<String>.from(map['acceptedMaterials']),
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

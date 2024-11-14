import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_moviles/models/recycling_location.dart';

class DatabaseLocation {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
   CollectionReference? collectionReference;

  //creamos un constructor
  DatabaseLocation(){
  //instanciamos el collectionReference
  collectionReference= firebaseFirestore.collection('locations');

  }

  Future<void> addRecyclingLocation(RecyclingLocation location) async {
    final db = FirebaseFirestore.instance;
    await db.collection('recycling_locations').add(location.toMap());
  }

Future<List<RecyclingLocation>> getRecyclingLocations() async {
      final db = FirebaseFirestore.instance;
      final querySnapshot = await db.collection('recycling_locations').get();
      
      return querySnapshot.docs.map((doc) {
        return RecyclingLocation.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
  }

}
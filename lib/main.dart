import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles/screens/add_location_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que la app esté completamente inicializada
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AddLocationScreen(),
    );
  }
}

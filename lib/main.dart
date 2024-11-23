import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles/screens/add_location_screen.dart';
import 'package:proyecto_moviles/screens/home_screen.dart';
import 'package:proyecto_moviles/screens/login_screen.dart';
import 'package:proyecto_moviles/screens/onboarding_screen.dart';
import 'package:proyecto_moviles/screens/recycling_map_screen.dart';
import 'package:proyecto_moviles/screens/register_screen.dart';

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
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
       "/home": (context) => const HomeScreen(),
       "/recycling_map": (context) => RecyclingMapScreen(),
       "/add_location": (context) => AddLocationScreen(),
       "/login": (context) => const LoginScreen(),
       "/register": (context) => const RegisterScreen(),
       "/onboarding": (context) => OnboardingScreen(),
      },
    );
  }
}

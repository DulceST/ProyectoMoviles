import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles/screens/add_location_screen.dart';
import 'package:proyecto_moviles/screens/home_screen.dart';
import 'package:proyecto_moviles/screens/information_screen.dart';
import 'package:proyecto_moviles/screens/login_screen.dart';
import 'package:proyecto_moviles/screens/onboarding_screen.dart';
import 'package:proyecto_moviles/screens/profile_screen.dart';
import 'package:proyecto_moviles/screens/recycling_map_screen.dart';
import 'package:proyecto_moviles/screens/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que la app esté completamente inicializada
  await Firebase.initializeApp(); // Inicializa Firebase
   await Supabase.initialize(
    url: 'https://mseaicoorljglkygdkbv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zZWFpY29vcmxqZ2xreWdka2J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTk2NTIsImV4cCI6MjA0ODIzNTY1Mn0.o8tn0SNf7JdP3jQypWecy9i6XX1Q8TK1CNQMIwGrYzM',
  );
  /*await Supabase.initialize(
  url: 'https://dfnuozwjrdndrnissctb.supabase.co', // URL de tu proyecto Supabase
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmbnVvendqcmRuZHJuaXNzY3RiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIzODAwODksImV4cCI6MjA0Nzk1NjA4OX0.ER-Coa02hsXuf5ufdIVroYRXr8gDsAEbiux2lNV8bN4',
  );*/
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
       "/recycling_map": (context) => const RecyclingMapScreen(),
       "/add_location": (context) => AddLocationScreen(),
       "/login": (context) => const LoginScreen(),
       "/register": (context) => const RegisterScreen(),
       "/onboarding": (context) => const OnboardingScreen(),
       "/profile": (context) => const ProfileScreen(),
        "/information":(context) => InformationScreen(),
      },
    );
  }
}

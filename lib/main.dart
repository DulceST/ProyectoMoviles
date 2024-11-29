import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_moviles/providers/theme_provider.dart';
import 'package:proyecto_moviles/screens/add_event_screen.dart';
import 'package:proyecto_moviles/screens/add_location_screen.dart';
import 'package:proyecto_moviles/screens/customize_screen.dart';
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

    WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize( //inicializa supabase
    url: 'https://mseaicoorljglkygdkbv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zZWFpY29vcmxqZ2xreWdka2J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTk2NTIsImV4cCI6MjA0ODIzNTY1Mn0.o8tn0SNf7JdP3jQypWecy9i6XX1Q8TK1CNQMIwGrYzM',
  );
    // Configuración de Flutter Local Notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await FlutterLocalNotificationsPlugin().initialize(initializationSettings);

  final themeProvider = ThemeProvider();
  await themeProvider.loadDrawerColor(); // Cargar color guardado

  
  runApp(ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const MainApp(),
  ),);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

   @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: ThemeData(
            primaryColor: themeProvider.drawerColor,
            fontFamily: themeProvider.fontFamily,
          ),
          debugShowCheckedModeBanner: false,
          home: const LoginScreen(), // Pantalla inicial
          routes: {
            "/home": (context) => const HomeScreen(),
            "/recycling_map": (context) => RecyclingMapScreen(),
            "/add_location": (context) => AddLocationScreen(),
            "/login": (context) => const LoginScreen(),
            "/register": (context) => const RegisterScreen(),
            "/profile": (context) => const ProfileScreen(),
            "/information": (context) => InformationScreen(),
            "/onboarding": (context) => const OnboardingScreen(),
            "/add_event": (context) => AddEventScreen(),
            "/color": (context) => const CustomizeScreen(),
          },
        );
      },
    );
  }
}
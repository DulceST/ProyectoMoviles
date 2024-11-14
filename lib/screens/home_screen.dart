import 'package:animated_floating_buttons/widgets/animated_floating_action_button.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proyecto_moviles/screens/recycling_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final GlobalKey<AnimatedFloatingActionButtonState> key =GlobalKey<AnimatedFloatingActionButtonState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: ConvexAppBar(
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.map, title: 'Recycling Map'),
          TabItem(icon: Icons.exit_to_app, title: 'Exit'),
        ],
        initialActiveIndex: 0,
        onTap: (int index) {
          if (index == 1) {
            Navigator.pushNamed(context, "/recycling_map");
          }
        },
      ),


    );
  }
}
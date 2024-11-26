import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

class InformationScreen extends StatelessWidget {
  InformationScreen({super.key});

  final List<Map<String, String>> recyclableItems = [
    {
      'title': 'Botellas de plástico',
      'image': 'https://mseaicoorljglkygdkbv.supabase.co/storage/v1/object/public/proyectomoviles/botellas_plastico.png',
      'backgroundImage': 'https://mseaicoorljglkygdkbv.supabase.co/storage/v1/object/public/proyectomoviles/fondo_botellas.jpg',
       'description': 'Las botellas de plástico pueden ser recicladas para crear nuevos envases y fibras textiles.'
    },
    {
      'title': 'Papel y cartón',
      'image': 'https://mseaicoorljglkygdkbv.supabase.co/storage/v1/object/public/proyectomoviles/papel_carton.png',
      'backgroundImage': 'https://mseaicoorljglkygdkbv.supabase.co/storage/v1/object/public/proyectomoviles/fondo_carton.jpg',
      'description': 'El papel y cartón reciclado ayuda a reducir la tala de árboles y el desperdicio.'
    },
    {
      'title': 'Latas de aluminio',
      'image': 'https://mseaicoorljglkygdkbv.supabase.co/storage/v1/object/public/proyectomoviles/lata.png',
      'backgroundImage': 'https://mseaicoorljglkygdkbv.supabase.co/storage/v1/object/public/proyectomoviles/fondo_latas.jpg',
      'description': 'Las latas de aluminio son 100% reciclables y pueden ser reutilizadas infinitamente.'
    },
    {
      'title': 'Vidrio',
      'image': 'https://mseaicoorljglkygdkbv.supabase.co/storage/v1/object/public/proyectomoviles/vidrio.png',
      'backgroundImage': 'https://mseaicoorljglkygdkbv.supabase.co/storage/v1/object/public/proyectomoviles/fondo_vidrio.jpg',
      'description': 'El vidrio reciclado puede transformarse en nuevos frascos, botellas o materiales de construcción.'
    },
  ];

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4,
              child: Stack(
                children: [
                  // Imagen de fondo específica para cada carta
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      image: DecorationImage(
                        image: NetworkImage(recyclableItems[index]['backgroundImage']!), // Imagen de fondo
                        fit: BoxFit.cover,
                        opacity: .5,
                      ),
                    ),
                  ),
                  // Contenido encima de la imagen de fondo
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        recyclableItems[index]['image']!,
                        height: 350,
                      ),
                      const SizedBox(height: 16),
                      // Fondo semitransparente para el título
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6), // Fondo semitransparente
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          recyclableItems[index]['title']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Contraste con el fondo
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Fondo semitransparente para la descripción
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6), // Fondo semitransparente
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          recyclableItems[index]['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white, // Contraste con el fondo
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          itemCount: recyclableItems.length,
          autoplay: true,
          pagination: const SwiperPagination(),
          control: const SwiperControl(),
        ),
      ),
    );
  }
}
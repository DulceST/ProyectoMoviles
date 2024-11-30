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
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 8,
              child: Stack(
                children: [
                  // Imagen de fondo específica para cada carta
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      image: DecorationImage(
                        image: NetworkImage(recyclableItems[index]['backgroundImage']!),
                        fit: BoxFit.cover,
                        opacity: 0.7,
                      ),
                    ),
                  ),
                  // Contenido encima de la imagen de fondo
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Image.network(
                          recyclableItems[index]['image']!,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0),
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              recyclableItems[index]['title']!,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              recyclableItems[index]['description']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            );
          },
          itemCount: recyclableItems.length,
          autoplay: true,
          autoplayDelay: 5000,
          pagination: const SwiperPagination(
            builder: DotSwiperPaginationBuilder(
              activeColor: Colors.white,
              color: Colors.grey,
            ),
          ),
          control: const SwiperControl(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

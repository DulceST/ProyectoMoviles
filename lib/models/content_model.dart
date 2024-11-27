class UnbordingContent {
  final String? lottie;
  final String title;
  final String description;

  UnbordingContent({this.lottie, required this.title, required this.description});
}

List<UnbordingContent> contents = [
  UnbordingContent(
    title: 'Bienvenido a VerdeVida',
    lottie: 'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/Animation%20-%201732576248520.json',
    description: "Con VerdeVida podrás encontrar los puntos de reciclaje más cercanos en tu ciudad. "
                 "Descubre cómo puedes contribuir al medio ambiente de manera simple y eficiente.",
  ),
  UnbordingContent(
    title: 'Encuentra puntos de reciclaje',
    lottie: 'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/Animation%20-%201732595404760.json',
     description: "Elige el material que deseas reciclar y encuentra los puntos cercanos que lo reciben.",
  ),
  UnbordingContent(
    title: 'Regístrate y Únete',
    //lottie: 'https://dfnuozwjrdndrnissctb.supabase.co/storage/v1/object/public/users/Animation%20-%201732602797744.json',
    description: "Ingresa tus datos para formar parte de la comunidad VerdeVida y contribuir al reciclaje. "
                 "Juntos podemos construir un mundo más limpio y sostenible para todos.",
  ),
];
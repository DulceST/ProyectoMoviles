class UnbordingContent {
  final String? lottie;
  final String title;
  final String description;

  UnbordingContent({this.lottie, required this.title, required this.description});
}

List<UnbordingContent> contents = [
  UnbordingContent(
    title: 'Bienvenido a VerdeVida',
    lottie: 'assets/reciclaje.json',
    description: "Encuentra los puntos de reciclaje más cercanos y contribuye al cuidado del medio ambiente.",
  ),
  UnbordingContent(
    title: 'Encuentra puntos de reciclaje',
    lottie: 'assets/material.json',
    description: "Selecciona el material a reciclar y ubica los puntos más cercanos.",
  ),
  UnbordingContent(
    title: 'Regístrate y Únete',
    lottie: 'assets/user.json',
    description: "Únete a la comunidad VerdeVida, registra tus datos y ayuda a hacer del mundo un lugar más limpio.",
  ),
];
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ActiveEventsScreen extends StatefulWidget {
  const ActiveEventsScreen({super.key});

  @override
  State<ActiveEventsScreen> createState() => _ActiveEventsScreenState();
}

class _ActiveEventsScreenState extends State<ActiveEventsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Set<String> subscribedEvents = {};

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    _initializeLocalNotifications();
    _loadUserSubscriptions();
  }

  /// Inicializar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await localNotificationsPlugin.initialize(initializationSettings);
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'subscription_channel', // ID del canal
      'Suscripciones', // Nombre del canal
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await localNotificationsPlugin.show(
      0, // ID de la notificación
      title, // Título
      body, // Cuerpo
      platformChannelSpecifics,
    );
  }

  /// Cargar las suscripciones del usuario actual
  Future<void> _loadUserSubscriptions() async {
    if (currentUser == null) return;

    final userSubscriptions = await FirebaseFirestore.instance
        .collection('subscriptions')
        .where('user_id', isEqualTo: currentUser!.uid)
        .get();

    setState(() {
      subscribedEvents = userSubscriptions.docs
          .map((doc) => doc['event_id'] as String)
          .toSet();
    });
  }

  /// Método para suscribirse a un evento
  Future<void> subscribeToEvent(String eventId, String eventName) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para suscribirte.')),
      );
      return;
    }

    try {
      // Agregar la suscripción del usuario a la colección 'subscriptions'
      await FirebaseFirestore.instance.collection('subscriptions').add({
        'event_id': eventId,
        'user_id': currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Agregar el ID del evento al estado local para mostrar "Suscrito"
      setState(() {
        subscribedEvents.add(eventId);
      });

      // Mostrar notificación local
      await _showLocalNotification(
        '¡Suscripción exitosa!',
        'Te has suscrito al evento: $eventName',
      );

      // Suscribirse al tema del evento para futuras notificaciones
      await messaging.subscribeToTopic(eventId);

      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Te has suscrito al evento "$eventName"!')),
      );
    } catch (e) {
      print('Error al suscribirse: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un error al suscribirse.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recycling_events')
            .orderBy('start_date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay eventos disponibles'));
          }

          final now = DateTime.now();

          final activeEvents = snapshot.data!.docs.where((event) {
            final startDate = (event['start_date'] as Timestamp).toDate();
            final durationDays = event['duration_days'] ?? 0;
            final endDate = startDate.add(Duration(days: durationDays));
            return now.isAfter(startDate) && now.isBefore(endDate);
          }).toList();

          if (activeEvents.isEmpty) {
            return const Center(child: Text('No hay eventos activos actualmente'));
          }

          return ListView.builder(
            itemCount: activeEvents.length,
            itemBuilder: (context, index) {
              final event = activeEvents[index];
              final eventId = event.id;
              final eventName = event['name'];
              final startDate = (event['start_date'] as Timestamp).toDate();
              final durationDays = event['duration_days'] ?? 0;
              final endDate = startDate.add(Duration(days: durationDays));
              final isSubscribed = subscribedEvents.contains(eventId);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(eventName),
                  subtitle: Text(
                    'Del ${startDate.toLocal().toString().split(' ')[0]} al ${endDate.toLocal().toString().split(' ')[0]}\n${event['description']}',
                  ),
                  trailing: isSubscribed
                      ? const Text(
                          'Suscrito',
                          style: TextStyle(color: Colors.green),
                        )
                      : ElevatedButton(
                          onPressed: () => subscribeToEvent(eventId, eventName),
                          child: const Text('Suscribirse'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

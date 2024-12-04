import 'package:accordion/accordion.dart';
import 'package:accordion/accordion_section.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_moviles/providers/theme_provider.dart';

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

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await localNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'subscription_channel', 
      'Suscripciones', 
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await localNotificationsPlugin.show(
      0, 
      title, 
      body, 
      platformChannelSpecifics,
    );
  }

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

  Future<void> subscribeToEvent(String eventId, String eventName) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para suscribirte.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('subscriptions').add({
        'event_id': eventId,
        'user_id': currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        subscribedEvents.add(eventId);
      });

      await _showLocalNotification(
        '¡Suscripción exitosa!',
        'Te has suscrito al evento: $eventName',
      );

      await messaging.subscribeToTopic(eventId);

    } catch (e) {
      print('Error al suscribirse: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un error al suscribirse.')),
      );
    }
  }

  Future<void> unsubscribeFromEvent(String eventId, String eventName) async {
    if (currentUser == null) return;

    try {
      final userSubscriptions = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('user_id', isEqualTo: currentUser!.uid)
          .where('event_id', isEqualTo: eventId)
          .get();

      for (final doc in userSubscriptions.docs) {
        await doc.reference.delete();
      }

      setState(() {
        subscribedEvents.remove(eventId);
      });

      await _showLocalNotification(
        '¡Suscripción cancelada!',
        'Has cancelado tu suscripción al evento: $eventName',
      );

      await messaging.unsubscribeFromTopic(eventId);

    } catch (e) {
      print('Error al cancelar suscripción: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un error al cancelar la suscripción.')),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);

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

        return Accordion(
          maxOpenSections: 1,
          headerBackgroundColor: themeProvider.primaryColor, // Color dinámico del encabezado
          contentBackgroundColor: themeProvider.cardColor, // Color dinámico del contenido
          headerPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          children: activeEvents.map((event) {
            final eventId = event.id;
            final eventName = event['name'];
            final startDate = (event['start_date'] as Timestamp).toDate();
            final durationDays = event['duration_days'] ?? 0;
            final endDate = startDate.add(Duration(days: durationDays));
            final isSubscribed = subscribedEvents.contains(eventId);

            return AccordionSection(
              header: Text(
                eventName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Del ${startDate.toLocal().toString().split(' ')[0]} al ${endDate.toLocal().toString().split(' ')[0]}\n${event['description']}',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  isSubscribed
                      ? ElevatedButton.icon(
                          onPressed: () => unsubscribeFromEvent(eventId, eventName),
                          icon: const Icon(Icons.cancel, color: Colors.white),
                          label: const Text('Cancelar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 245, 164, 159),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => subscribeToEvent(eventId, eventName),
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                          label: const Text(
                            'Suscribirse',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 161, 225, 163),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ],
              ),
            );
          }).toList(),
        );
      },
    ),
  );
}
}
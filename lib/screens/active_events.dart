import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveEventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos Activos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recycling_events')
            .orderBy('start_date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay eventos disponibles'));
          }

          final now = DateTime.now();

          final activeEvents = snapshot.data!.docs.where((event) {
            final startDate = (event['start_date'] as Timestamp).toDate();
            final durationDays = event['duration_days'] ?? 0;
            final endDate = startDate.add(Duration(days: durationDays));
            return now.isAfter(startDate) && now.isBefore(endDate);
          }).toList();

          if (activeEvents.isEmpty) {
            return Center(child: Text('No hay eventos activos actualmente'));
          }

          return ListView.builder(
            itemCount: activeEvents.length,
            itemBuilder: (context, index) {
              final event = activeEvents[index];
              final startDate = (event['start_date'] as Timestamp).toDate();
              final durationDays = event['duration_days'] ?? 0;
              final endDate = startDate.add(Duration(days: durationDays));

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(event['name']),
                  subtitle: Text(
                    'Del ${startDate.toLocal().toString().split(' ')[0]} al ${endDate.toLocal().toString().split(' ')[0]}\n${event['description']}',
                  ),
                  trailing: Icon(Icons.event_available),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

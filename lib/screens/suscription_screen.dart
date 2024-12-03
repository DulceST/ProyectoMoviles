import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_moviles/screens/payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> subscriptions_pay = [];

  @override
  void initState() {
    super.initState();
    _fetchSubscriptions();
  }

Future<void> _fetchSubscriptions() async {
  try {
    QuerySnapshot snapshot = await _firestore.collection('subscriptions_pay').get();
    setState(() {
      subscriptions_pay = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data, // Incluye todos los campos del documento
        };
      }).toList();
    });
  } catch (e) {
    print('Error fetching subscriptions_pay: $e');
  }
}

  void _handleSubscriptionTap(Map<String, dynamic> subscription) async {
    try {
      bool? paymentSuccess = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(subscription: subscription),
        ),
      );

      if (paymentSuccess == true) {
        await _updateUserSubscription(subscription);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed, please try again')),
        );
      }
    } catch (e) {
      print('Error handling subscription tap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }



  Future<bool> _simulatePayment(String subscriptionName) async {
    // Mock payment logic
    return await Future.delayed(Duration(seconds: 2), () => true);
  }

Future<void> _updateUserSubscription(Map<String, dynamic> subscription) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is logged in.');
    }

    String userId = user.uid;

    // Calcular la fecha de expiración según el tipo de suscripción
    DateTime now = DateTime.now();
    DateTime expiryDate;

    if (subscription.containsKey('type')) {
      switch (subscription['type'].toLowerCase()) {
        case 'mensual':
          expiryDate = now.add(Duration(days: 30));
          break;
        case 'semestral':
          expiryDate = now.add(Duration(days: 182));
          break;
        case 'anual':
          expiryDate = now.add(Duration(days: 365));
          break;
        default:
          throw Exception('Unknown subscription type: ${subscription['type']}');
      }
    } else {
      throw Exception('Subscription type is missing.');
    }

    // Guardar los datos de la suscripción en Firestore
    Map<String, dynamic> paySubscriptionData = {
      'type': subscription['type'],
      'price': subscription['price'],
      'name': subscription['name'],
      'description': subscription['description'],
      'expiryDate': expiryDate.toIso8601String(),
    };

    await _firestore.collection('users').doc(userId).set({
      'pay_subscription': paySubscriptionData, // Guardar en el campo 'pay_subscription'
    }, SetOptions(merge: true));

    // Actualizar el estado de la UI para reflejar los cambios
    setState(() {
      // Aquí actualizas el estado local con la nueva suscripción
      // Esto podría implicar actualizar alguna variable o llamar de nuevo al método de carga de la suscripción si es necesario
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Subscription updated successfully!')),
    );
  } catch (e) {
    print('Error updating subscription: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update subscription.')),
    );
  }
}

Future<Map<String, dynamic>> _getUserSubscription() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is logged in.');
    }

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  } catch (e) {
    print('Error fetching user subscription: $e');
    return {};
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Elige tu suscripcion', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserSubscription(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading subscription status.'));
          } else {
            final userSubscription = snapshot.data ?? {};
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userSubscription.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suscripcion Activa: ${userSubscription['pay_subscription']?['name'] ?? 'None'}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Fecha de expiración: ${userSubscription['pay_subscription']?['expiryDate'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 16, color: Colors.blue[600]),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                  Text(
                    'Sucripciones disponibles',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: subscriptions_pay.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : CarouselSlider(
                            options: CarouselOptions(
                              height: 400,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              aspectRatio: 16 / 9,
                              viewportFraction: 0.8,
                            ),
                            items: subscriptions_pay.map((subscription) {
                              return GestureDetector(
                                onTap: () => _handleSubscriptionTap(subscription),
                                child: Card(
                                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.black.withOpacity(0.2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        subscription['name'],
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '\$${subscription['price']}',
                                        style: TextStyle(fontSize: 20, color: Colors.green),
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          subscription['description'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
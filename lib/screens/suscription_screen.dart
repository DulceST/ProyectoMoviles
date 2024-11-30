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
        subscriptions_pay = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching subscriptions_pay: $e');
    }
  }

  void _handleSubscriptionTap(Map<String, dynamic> subscription) async {
    // Navegar a la pantalla de pago
    bool? paymentSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(subscription: subscription),
      ),
    );

    if (paymentSuccess == true) {
      _updateUserSubscription(subscription);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed, please try again')),
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

    DateTime now = DateTime.now();
    DateTime expiryDate;

    switch (subscription['type']) {
      case 'monthly':
        expiryDate = now.add(Duration(days: 30));
        break;
      case 'semiannual':
        expiryDate = now.add(Duration(days: 182));
        break;
      case 'annual':
        expiryDate = now.add(Duration(days: 365));
        break;
      default:
        expiryDate = now;
    }

    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    await _firestore.collection('users').doc('USER_ID').set({
      'currentSubscription': subscription['id'],
      'subscriptionExpiry': expiryDate,
    }, SetOptions(merge: true));

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Subscription'),
      ),
      body: subscriptions_pay.isEmpty
          ? Center(child: CircularProgressIndicator())
          : CarouselSlider(
              options: CarouselOptions(
                height: 400,
                enlargeCenterPage: true,
                autoPlay: true,
              ),
              items: subscriptions_pay.map((subscription) {
                return GestureDetector(
                  onTap: () => _handleSubscriptionTap(subscription),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subscription['name'],
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '\$${subscription['price']}',
                          style: TextStyle(fontSize: 20, color: Colors.green),
                        ),
                        SizedBox(height: 10),
                        Text(subscription['description']),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

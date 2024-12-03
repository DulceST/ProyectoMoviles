import 'package:flutter/material.dart';
import 'package:proyecto_moviles/services/stripe_service.dart';

class PaymentScreen extends StatelessWidget {
  final Map<String, dynamic> subscription;

  PaymentScreen({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment for ${subscription['name']}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You are about to pay for ${subscription['name']}'),
            SizedBox(height: 20),
            Text('Amount: \$${subscription['price']}'),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(child: CircularProgressIndicator()),
                );
                // Proceso de pago con Stripe
                bool paymentSuccess = await _processPayment(subscription, context);
                Navigator.pop(context); // Cierra el diálogo de carga
                if (paymentSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment Successful!')),
                  );
                  Navigator.pop(context, true); // Regresa confirmando éxito
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment Failed. Please try again.')),
                  );
                }
              },
              child: Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _processPayment(Map<String, dynamic> subscription, BuildContext context) async {
    try {
      // Convertir el monto a centavos (Stripe usa valores enteros)
      int amountInCents = (subscription['price'] * 100).toInt();
      await StripeService.instance.makePayment(
        amount: amountInCents,
        currency: 'usd',
      );
      return true; // Éxito
    } catch (e) {
      print('Error during payment: $e');
      return false; // Fallo
    }
  }
}

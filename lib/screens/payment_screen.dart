import 'package:flutter/material.dart';

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
                // Aquí puedes integrar el proceso de pago real
                bool paymentSuccess = await _processPayment(subscription);
                if (paymentSuccess) {
                  Navigator.pop(context, true);  // Volver y confirmar éxito
                } else {
                  Navigator.pop(context, false); // Volver y confirmar fallo
                }
              },
              child: Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _processPayment(Map<String, dynamic> subscription) async {
    // Implementar lógica de pago aquí, por ejemplo, usando un servicio de pago.
    return await Future.delayed(Duration(seconds: 2), () => true);  // Simulación de pago
  }
}    
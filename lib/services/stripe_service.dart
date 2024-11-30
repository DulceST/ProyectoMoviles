import 'dart:convert';
import 'package:http/http.dart' as http;

class StripeService {
  final String _baseUrl = 'https://api.stripe.com/v1';
  final String _secretKey = 'sk_test_51QQtmdGPGfsJXUQgdTUOJx52e0cOEWjpyGXfKHJ7SvGX84Sz6KiO7cLAK8BLRzbdROzdBaNNUWc2MJC8yA5BS1A600j1SO0659'; // Reemplaza con tu clave secreta

  Future<String> createPaymentIntent(double amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).toInt().toString(), // Stripe usa valores en centavos
          'currency': currency,
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['client_secret'];
      } else {
        throw Exception('Error al crear PaymentIntent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en el servicio Stripe: $e');
    }
  }
}

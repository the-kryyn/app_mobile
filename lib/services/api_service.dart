import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'base_url_service.dart';

class ApiService {
  /// Toggle for test mode: if true, return random values
  static bool useFakeData = false;

  static Future<double> fetchSalinity() async {
    if (useFakeData) {
      return _generateFakeSalinity();
    }

    final baseUrl = BaseUrlService.getBaseUrl();
    final uri = Uri.parse('$baseUrl/salinity');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('value')) {
          final rawValue = data['value'].toString();

          // Remove any non-numeric characters (except . and - for decimal/negative)
          final cleaned = rawValue.replaceAll(RegExp('[^0-9.-]'), '');

          if (cleaned.isEmpty || double.tryParse(cleaned) == null) {
            throw Exception('Valeur invalide pour la salinité: "$rawValue"');
          }

          final salinity = double.parse(cleaned);

          // Check for special value indicating a connection without data
          if (salinity == -1) {
            throw Exception(
              'Capteur connecté, mais aucune donnée reçue (vérifiez la connexion LoRa).',
            );
          }

          return salinity;
        } else {
          throw Exception('Clé "value" absente dans la réponse.');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on TimeoutException {
      throw TimeoutException("La requête a expiré.");
    } catch (e) {
      throw Exception("Erreur lors de la récupération de la salinité: $e");
    }
  }

  static double _generateFakeSalinity() {
    final random = Random();
    // Simulate salinity between 20.0 and 40.0 (adjust as needed)
    return 20 + random.nextDouble() * 20;
  }
}

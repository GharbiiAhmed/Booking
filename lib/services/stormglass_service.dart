import 'dart:convert';
import 'package:http/http.dart' as http;

class StormglassService {
  final String apiKey = '4aaa59e4-9c21-11ef-8d8d-0242ac130003-4aaa5a5c-9c21-11ef-8d8d-0242ac130003';
  final String baseUrl = 'https://api.stormglass.io/v2';

  Future<Map<String, dynamic>> fetchMarineData(double lat, double lng) async {
    final url = Uri.parse('$baseUrl/weather/point?lat=$lat&lng=$lng&params=windSpeed,airTemperature');

    final response = await http.get(
      url,
      headers: {
        'Authorization': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data from Stormglass');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey =
      'da9d59d4163ce35cb9cffc11338b679d'; // Replace with your API key
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = '$baseUrl?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> _weatherData;
  final String apiKey = 'da9d59d4163ce35cb9cffc11338b679d'; // API key
  final String city = 'Sulaymaniyah'; // Nawi Shar

  @override
  void initState() {
    super.initState();
    _weatherData = fetchWeatherData(); // Fetch live weather data
  }

  // Rakeshani Data la OpenWeather API
  Future<Map<String, dynamic>> fetchWeatherData() async {
    final String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather data: $e'); // la 7allati habuni errorek
      throw Exception('Error fetching weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather in Sulaymaniyah'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child:
                    Text('Error: ${snapshot.error}')); // peshandaniay erroraka
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No weather data available'));
          } else {
            final data = snapshot.data!;
            final double temperature = data['main']['temp'];
            final double tempMin = data['main']['temp_min'];
            final double tempMax = data['main']['temp_max'];
            final int pressure = data['main']['pressure']; //pastan
            final int humidity = data['main']['humidity'];
            final int cloudiness = data['clouds']['all'];
            final String weatherDescription = data['weather'][0]['description'];
            final double windSpeed = data['wind']['speed'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWeatherInfo(
                    temperature: temperature,
                    feelsLike: data['main']['feels_like'],
                    tempMin: tempMin,
                    tempMax: tempMax,
                    weatherDescription: weatherDescription,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _weatherInfoCard(Icons.thermostat_outlined, 'Pressure',
                          '$pressure hPa'),
                      _weatherInfoCard(
                          Icons.cloud, 'Cloudiness', '$cloudiness%'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _weatherInfoCard(
                          Icons.water_drop, 'Humidity', '$humidity%'),
                      _weatherInfoCard(
                          Icons.air, 'Wind Speed', '$windSpeed m/s'),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Helper method for building the main temperature info
  Widget _buildWeatherInfo({
    required double temperature,
    required double feelsLike,
    required double tempMin,
    required double tempMax,
    required String weatherDescription,
  }) {
    return Column(
      children: [
        Text(
          '${temperature.toStringAsFixed(1)}°C',
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          weatherDescription.toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _weatherDetailCard(
                'Feels like', '${feelsLike.toStringAsFixed(1)}°C'),
            _weatherDetailCard('Min Temp', '${tempMin.toStringAsFixed(1)}°C'),
            _weatherDetailCard('Max Temp', '${tempMax.toStringAsFixed(1)}°C'),
          ],
        ),
      ],
    );
  }

  // Helper method for the individual weather info cards
  Widget _weatherInfoCard(IconData icon, String label, String value) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.teal, size: 40),
            const SizedBox(height: 20,width: 120),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for the temperature detail cards
  Widget _weatherDetailCard(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

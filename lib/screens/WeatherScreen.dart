import 'package:flutter/material.dart';
import '../services/stormglass_service.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final StormglassService stormglassService = StormglassService();
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      final data = await stormglassService.fetchMarineData(37.7749, -122.4194); // Use your latitude and longitude
      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather Data')),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : weatherData != null
            ? Text('Temperature: ${weatherData!['hours'][0]['airTemperature']['noaa']} °C')
            : Text('Failed to load weather data'),
      ),
    );
  }
}

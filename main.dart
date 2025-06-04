// SkyLens – Holografikus Időjárás App (Flutter v3 + OpenWeatherMap API)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(SkyLensApp());
}

class SkyLensApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: GoogleFonts.orbitron().fontFamily,
        colorScheme: ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.deepPurpleAccent,
        ),
      ),
      home: WeatherDashboard(),
    );
  }
}

class WeatherDashboard extends StatefulWidget {
  @override
  _WeatherDashboardState createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  String city = 'Betöltés...';
  String description = '';
  int temperature = 0;
  List<dynamic> forecast = [];

  @override
  void initState() {
    super.initState();
    getLocationAndWeather();
  }

  Future<void> getLocationAndWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await fetchWeather(position.latitude, position.longitude);
    } catch (e) {
      print('Lokáció hiba: \$e');
    }
  }

  Future<void> fetchWeather(double lat, double lon) async {
    const String apiKey = 'b59d5130f9ab1417adcc43a7a382474e';
    final currentUrl = 'https://api.openweathermap.org/data/2.5/weather?lat=\$lat&lon=\$lon&units=metric&lang=hu&appid=\$apiKey';
    final forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast?lat=\$lat&lon=\$lon&units=metric&lang=hu&appid=\$apiKey';

    final currentResponse = await http.get(Uri.parse(currentUrl));
    final forecastResponse = await http.get(Uri.parse(forecastUrl));

    if (currentResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
      final currentData = json.decode(currentResponse.body);
      final forecastData = json.decode(forecastResponse.body);

      setState(() {
        city = currentData['name'];
        description = currentData['weather'][0]['description'];
        temperature = currentData['main']['temp'].round();
        forecast = forecastData['list'].take(7).toList();
      });
    } else {
      print('Hiba az adatok lekérésénél.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SkyLens'),
        backgroundColor: Colors.black.withOpacity(0.6),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Text(
            city,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Icon(Icons.wb_sunny_rounded, size: 80, color: Colors.amber),
          const SizedBox(height: 10),
          Text(
            '\$temperature°C – \$description',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 30),
          Divider(color: Colors.cyanAccent.withOpacity(0.4)),
          const SizedBox(height: 10),
          Text(
            'Előrejelzés',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          forecast.isNotEmpty
              ? Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: forecast.map((entry) {
                      final temp = entry['main']['temp'].round();
                      final date = entry['dt_txt'].toString().split(' ')[0];
                      final desc = entry['weather'][0]['description'];
                      return ForecastCard(day: date, temp: '\$temp°C', desc: desc);
                    }).toList(),
                  ),
                )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class ForecastCard extends StatelessWidget {
  final String day;
  final String temp;
  final String desc;

  ForecastCard({required this.day, required this.temp, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.withOpacity(0.4), Colors.deepPurple.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: TextStyle(fontSize: 14)),
          const SizedBox(height: 6),
          Icon(Icons.cloud, size: 32),
          const SizedBox(height: 6),
          Text(temp, style: TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
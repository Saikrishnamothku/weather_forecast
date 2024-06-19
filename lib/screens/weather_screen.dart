import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../storage/city_storage.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService weatherService = WeatherService();
  final CityStorage cityStorage = CityStorage();
  final TextEditingController _controller = TextEditingController();

  String? _selectedCity;
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecast;

  @override
  void initState() {
    super.initState();
    _loadSavedCity();
  }

  Future<void> _loadSavedCity() async {
    _selectedCity = await cityStorage.getCity();
    if (_selectedCity != null) {
      _fetchWeatherData(_selectedCity!);
    }
  }

  Future<void> _fetchWeatherData(String city) async {
    try {
      final currentWeather = await weatherService.getCurrentWeather(city);
      final forecast = await weatherService.get5DayForecast(city);

      setState(() {
        _selectedCity = city;
        _currentWeather = currentWeather;
        _forecast = forecast;
      });

      await cityStorage.saveCity(city);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching weather data: $e', style: const TextStyle(fontFamily: 'Open'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast', style: TextStyle(fontFamily: 'Open')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade200,
                Colors.blue.shade300,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showNotifications(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade200,
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              if (_currentWeather != null) ...[
                _buildCurrentWeather(),
                const SizedBox(height: 20),
                _buildForecast(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _controller,
      style: const TextStyle(fontSize: 18, fontFamily: 'Open', color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Enter city',
        labelStyle: const TextStyle(fontSize: 16, fontFamily: 'Open', color: Colors.black),
        hintText: 'Search for a city',
        hintStyle: const TextStyle(fontSize: 16, fontFamily: 'Open', color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          color: Colors.black,
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              _fetchWeatherData(_controller.text);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCurrentWeather() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Weather in $_selectedCity',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Open'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Image.network(
              'http://openweathermap.org/img/w/${_currentWeather!['weather'][0]['icon']}.png',
              scale: 1.5,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Temperature: ${_currentWeather!['main']['temp']}°C', style: const TextStyle(fontSize: 18, fontFamily: 'Open')),
                Text('Condition: ${_currentWeather!['weather'][0]['description']}', style: const TextStyle(fontSize: 18, fontFamily: 'Open')),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForecast() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5-Days Forecast',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Open'),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _forecast!['list'].length,
              itemBuilder: (context, index) {
                final forecastItem = _forecast!['list'][index];
                final time = DateTime.parse(forecastItem['dt_txt']);
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      'http://openweathermap.org/img/w/${forecastItem['weather'][0]['icon']}.png',
                      scale: 1.5,
                    ),
                    title: Text(
                      '${time.day}/${time.month}/${time.year} ${time.hour}:00',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Open'),
                    ),
                    subtitle: Text(
                      'Temp: ${forecastItem['main']['temp']}°C, ${forecastItem['weather'][0]['description']}',
                      style: const TextStyle(fontSize: 16, fontFamily: 'Open'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notifications', style: TextStyle(fontFamily: 'Open')),
          content: const Text('You have no new notifications.', style: TextStyle(fontFamily: 'Open')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(fontFamily: 'Open')),
            ),
          ],
        );
      },
    );
  }
}

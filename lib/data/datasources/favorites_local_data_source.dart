import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/flight_model.dart';

class FavoritesLocalDataSource {
  static const String _favoritesKey = 'cached_favorites';

  Future<void> saveFavorite(FlightModel flight) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    
    // Check if already exists to avoid duplicates
    final exists = favoritesJson.any((jsonStr) {
      final existingFlight = FlightModel.fromJson(jsonDecode(jsonStr));
      return existingFlight.flightNumber == flight.flightNumber;
    });

    if (!exists) {
      // Add 'favoritedAt' timestamp
      final jsonMap = flight.toJson();
      jsonMap['favoritedAt'] = DateTime.now().toIso8601String();
      
      favoritesJson.add(jsonEncode(jsonMap));
      await prefs.setStringList(_favoritesKey, favoritesJson);
    }
  }

  Future<void> removeFavorite(String flightNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    
    favoritesJson.removeWhere((jsonStr) {
      final flight = FlightModel.fromJson(jsonDecode(jsonStr));
      return flight.flightNumber == flightNumber;
    });

    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  Future<List<FlightModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    return favoritesJson.map((jsonStr) {
      final jsonMap = jsonDecode(jsonStr);
      // We could extract 'favoritedAt' here if we broadened FlightModel or used a wrapper
      return FlightModel.fromJson(jsonMap);
    }).toList();
  }
  
  Future<Map<String, DateTime>> getFavoritesTimestamps() async {
     final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    final Map<String, DateTime> timestamps = {};
    for (var jsonStr in favoritesJson) {
      final jsonMap = jsonDecode(jsonStr);
      final flightNum = jsonMap['flight']['iata'] ?? jsonMap['flightNumber']; // support both structures if needed, but we used nested in toJson
      if (jsonMap.containsKey('favoritedAt')) {
        timestamps[flightNum] = DateTime.parse(jsonMap['favoritedAt']);
      }
    }
    return timestamps;
  }
}

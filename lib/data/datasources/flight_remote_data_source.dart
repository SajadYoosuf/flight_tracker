import '../models/flight_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

abstract class FlightRemoteDataSource {
  Future<List<FlightModel>> getFlights();
  Future<List<FlightModel>> searchFlights(String query);
}

class FlightRemoteDataSourceImpl implements FlightRemoteDataSource {
  final String _apiKey = 'efcf7804femsh56f201798fd8549p1323efjsn87d85d03fdf5';
  final String _apiHost = 'flymat-tracker-api.p.rapidapi.com';
  
  // Kerala Airports with Coordinates
  final List<Map<String, dynamic>> _keralaAirports = [
    {
      'name': 'Calicut',
      'icao': 'VOCL',
      'lat': 11.1374,
      'lng': 75.9556,
    },
    {
      'name': 'Cochin',
      'icao': 'VOCI',
      'lat': 10.1518,
      'lng': 76.3930,
    },
    {
      'name': 'Trivandrum',
      'icao': 'VOTV',
      'lat': 8.4821,
      'lng': 76.9200,
    },
    {
      'name': 'Kannur',
      'icao': 'VOKN',
      'lat': 11.9167,
      'lng': 75.5500,
    },
  ];

  @override
  Future<List<FlightModel>> getFlights() async {
    List<FlightModel> allFlights = [];

    // 1. Get User Location
    Position? userLocation;
    try {
      userLocation = await _getUserLocation();
    } catch (e) {
      print('Location error: $e');
    }

    // 2. Sort Airports by Distance if location available
    List<Map<String, dynamic>> sortedAirports = List.from(_keralaAirports);
    if (userLocation != null) {
      sortedAirports.sort((a, b) {
        final double distA = Geolocator.distanceBetween(
          userLocation!.latitude,
          userLocation!.longitude,
          a['lat'],
          a['lng'],
        );
        final double distB = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          b['lat'],
          b['lng'],
        );
        return distA.compareTo(distB);
      });
      print('Sorted Airports: ${sortedAirports.map((e) => e['name']).toList()}');
    }

    // 3. Fetch flights from sorted airports
    for (var airportData in sortedAirports) {
      final String airportCode = airportData['icao']!; // Using ICAO as requested
       try {
        final response = await http.post(
          Uri.parse('https://flymat-tracker-api.p.rapidapi.com/api/departure_schedule'),
          headers: {
            'x-rapidapi-key': _apiKey,
            'x-rapidapi-host': _apiHost,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "airport_code": airportCode,
            "max_value": DateTime.now().millisecondsSinceEpoch,
            "key": "mrgaporgic"
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            final dynamic remoteData = data['data'];
            List<dynamic>? list;

            if (remoteData is Map) {
               if (remoteData.containsKey('list') && remoteData['list'] is List) {
                  list = remoteData['list'];
               }
            } else if (remoteData is List) {
               list = remoteData;
            }

            if (list != null) {
              print('Loaded ${list.length} flights for ${airportData['name']} ($airportCode)');
              allFlights.addAll(list
                  .where((e) => e is Map)
                  .map((e) => FlightModel.fromFlyMatJson(e as Map<String, dynamic>))
                  .toList());
            } else {
               print('No list found for ${airportData['name']} in data');
            }
          }
        } else {
          print('Failed to load flights for ${airportData['name']}: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching flights for ${airportData['name']}: $e');
      }
    }
    
    // Fallback to sample BGAA if empty (just for demo purposes if mapped airports have no traffic)
    if (allFlights.isEmpty) {
       // Code for BGAA from sample
       try {
        final response = await http.post(
          Uri.parse('https://flymat-tracker-api.p.rapidapi.com/api/departure_schedule'),
          headers: {
            'x-rapidapi-key': _apiKey,
            'x-rapidapi-host': _apiHost,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "airport_code": "BGAA",
            "max_value": DateTime.now().millisecondsSinceEpoch,
            "key": "mrgaporgic" 
          }),
        );
         if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
             if (data['status'] == 'success') {
                 final dynamic remoteData = data['data'];
                 List<dynamic>? list;
                 if (remoteData is Map && remoteData.containsKey('list') && remoteData['list'] is List) {
                   list = remoteData['list'];
                 } else if (remoteData is List) {
                   list = remoteData;
                 }
                 
                 if (list != null) {
                    allFlights.addAll(list
                        .where((e) => e is Map)
                        .map((e) => FlightModel.fromFlyMatJson(e as Map<String, dynamic>))
                        .toList());
                 }
             }
         }
       } catch (e) { print('Error fetching BGAA: $e'); }
    }

    return allFlights;
  }

  Future<Position?> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    } 

    // Use approximate location (low accuracy) for speed as requested ("network location")
    // but Android explicit network provider isn't directly exposed via simple enum, 
    // adjusting accuracy to low/balanced often uses network.
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low, 
        timeLimit: Duration(seconds: 5)
      ),
    );
  }

  @override
  Future<List<FlightModel>> searchFlights(String query) async {
    // For now, filter local list. Real API search would need a different endpoint or parameter.
    final allFlights = await getFlights();
    return allFlights.where((flight) {
      final q = query.toLowerCase();
      return flight.flightNumber.toLowerCase().contains(q) ||
             flight.departureAirport.toLowerCase().contains(q) ||
             flight.arrivalAirport.toLowerCase().contains(q) ||
             flight.departureIata.toLowerCase().contains(q) ||
             flight.arrivalIata.toLowerCase().contains(q);
    }).toList();
  }
}

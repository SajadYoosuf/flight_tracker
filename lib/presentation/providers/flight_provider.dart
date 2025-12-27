import 'package:flutter/foundation.dart';
import '../../domain/entities/flight.dart';
import '../../domain/repositories/flight_repository.dart';

class FlightProvider with ChangeNotifier {
  final FlightRepository repository;
  
  List<Flight> _flights = [];
  List<Flight> get flights => _flights;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  FlightProvider({required this.repository});

  List<Flight>? _allFlights;

  Future<void> loadFlights() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await repository.getFlights();
      _flights = results;
      _allFlights = results;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchFlights(String query) {
    _isLoading = true;
    _error = null;
    
    // Safety check for hot-reload or uninitialized state
    if (_allFlights == null) {
      _allFlights = List.from(_flights);
    }
    
    if (query.isEmpty) {
      _flights = List.from(_allFlights!);
    } else {
      final q = query.toLowerCase();
      _flights = _allFlights!.where((flight) {
        return flight.flightNumber.toLowerCase().contains(q) ||
               flight.departureAirport.toLowerCase().contains(q) ||
               flight.arrivalAirport.toLowerCase().contains(q) ||
               flight.departureIata.toLowerCase().contains(q) ||
               flight.arrivalIata.toLowerCase().contains(q);
      }).toList();
    }
    
    _isLoading = false;
    notifyListeners();
  }
}

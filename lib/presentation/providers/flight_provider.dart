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

  Future<void> loadFlights() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _flights = await repository.getFlights();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchFlights(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (query.isEmpty) {
        await loadFlights();
      } else {
        _flights = await repository.searchFlights(query);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

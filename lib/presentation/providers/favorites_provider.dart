import 'package:flutter/material.dart';
import '../../domain/entities/flight.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesRepository repository;
  
  List<Flight> _favorites = [];
  Map<String, DateTime> _timestamps = {};
  bool _isLoading = false;
  String? _error;

  FavoritesProvider({required this.repository}); // Load explicitly or call loadFavorites in constructor? Better explicit.

  List<Flight> get favorites => _favorites;
  Map<String, DateTime> get timestamps => _timestamps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await repository.getFavorites();
      _timestamps = await repository.getFavoriteTimestamps();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String flightNumber) {
    return _favorites.any((f) => f.flightNumber == flightNumber);
  }

  Future<void> toggleFavorite(Flight flight) async {
    try {
      if (isFavorite(flight.flightNumber)) {
        await repository.removeFavorite(flight.flightNumber);
        _favorites.removeWhere((f) => f.flightNumber == flight.flightNumber);
        _timestamps.remove(flight.flightNumber);
      } else {
        await repository.saveFavorite(flight);
        _favorites.add(flight);
        _timestamps[flight.flightNumber] = DateTime.now();
      }
      notifyListeners();
    } catch (e) {
      _error = "Failed to update favorite";
      notifyListeners();
    }
  }
}

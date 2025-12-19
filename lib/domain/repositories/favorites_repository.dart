import '../../domain/entities/flight.dart';

abstract class FavoritesRepository {
  Future<void> saveFavorite(Flight flight);
  Future<void> removeFavorite(String flightNumber);
  Future<List<Flight>> getFavorites();
  Future<Map<String, DateTime>> getFavoriteTimestamps();
}

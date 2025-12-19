import '../../domain/entities/flight.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../models/flight_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource dataSource;

  FavoritesRepositoryImpl(this.dataSource);

  @override
  Future<List<Flight>> getFavorites() async {
    return await dataSource.getFavorites();
  }

  @override
  Future<void> removeFavorite(String flightNumber) async {
    await dataSource.removeFavorite(flightNumber);
  }

  @override
  Future<void> saveFavorite(Flight flight) async {
    // Convert entity to model
    final model = FlightModel(
      flightNumber: flight.flightNumber,
      airline: flight.airline,
      status: flight.status,
      departureAirport: flight.departureAirport,
      departureIata: flight.departureIata,
      arrivalAirport: flight.arrivalAirport,
      arrivalIata: flight.arrivalIata,
      departureTime: flight.departureTime,
      arrivalTime: flight.arrivalTime,
      gate: flight.gate,
      terminal: flight.terminal,
      delayMinutes: flight.delayMinutes,
    );
    await dataSource.saveFavorite(model);
  }

  @override
  Future<Map<String, DateTime>> getFavoriteTimestamps() async {
    return await dataSource.getFavoritesTimestamps();
  }
}

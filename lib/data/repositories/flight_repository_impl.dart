import '../../domain/entities/flight.dart';
import '../../domain/repositories/flight_repository.dart';
import '../datasources/flight_remote_data_source.dart';

class FlightRepositoryImpl implements FlightRepository {
  final FlightRemoteDataSource remoteDataSource;

  FlightRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Flight>> getFlights() async {
    return await remoteDataSource.getFlights();
  }

  @override
  Future<List<Flight>> searchFlights(String query) async {
    return await remoteDataSource.searchFlights(query);
  }

  @override
  Future<Flight?> getFlightDetails(String flightNumber) async {
    final flights = await remoteDataSource.getFlights();
    try {
      return flights.firstWhere((f) => f.flightNumber == flightNumber);
    } catch (_) {
      return null;
    }
  }
}

import '../entities/flight.dart';

abstract class FlightRepository {
  Future<List<Flight>> getFlights();
  Future<List<Flight>> searchFlights(String query);
  Future<Flight?> getFlightDetails(String flightNumber);
}

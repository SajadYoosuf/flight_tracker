import '../../domain/entities/flight.dart';

class FlightModel extends Flight {
  FlightModel({
    required super.flightNumber,
    required super.airline,
    required super.status,
    required super.departureAirport,
    required super.departureIata,
    required super.arrivalAirport,
    required super.arrivalIata,
    super.departureTime,
    super.arrivalTime,
    super.gate,
    super.terminal,
    super.delayMinutes,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    // This assumes a structure similar to AviationStack, 
    // but simplified for the mock.
    // In AviationStack: 'flight' object has 'iata', 'airline' has 'name', etc.
    
    final flightBlock = json['flight'] ?? {};
    final airlineBlock = json['airline'] ?? {};
    final depBlock = json['departure'] ?? {};
    final arrBlock = json['arrival'] ?? {};

    return FlightModel(
      flightNumber: flightBlock['iata'] ?? 'UNKNOWN',
      airline: airlineBlock['name'] ?? 'Unknown Airline',
      status: json['flight_status'] ?? 'scheduled',
      departureAirport: depBlock['airport'] ?? 'Unknown Airport',
      departureIata: depBlock['iata'] ?? '???',
      arrivalAirport: arrBlock['airport'] ?? 'Unknown Airport',
      arrivalIata: arrBlock['iata'] ?? '???',
      departureTime: depBlock['scheduled'] != null ? DateTime.parse(depBlock['scheduled']) : null,
      arrivalTime: arrBlock['scheduled'] != null ? DateTime.parse(arrBlock['scheduled']) : null,
      gate: depBlock['gate'],
      terminal: depBlock['terminal'],
      delayMinutes: depBlock['delay'],
    );
  }
}

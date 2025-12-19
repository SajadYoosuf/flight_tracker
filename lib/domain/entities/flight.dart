class Flight {
  final String flightNumber; // e.g., "AA123"
  final String airline;
  final String status; // active, scheduled, landed, cancelled
  final String departureAirport;
  final String departureIata;
  final String arrivalAirport;
  final String arrivalIata;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final String? gate;
  final String? terminal;
  final int? delayMinutes;

  Flight({
    required this.flightNumber,
    required this.airline,
    required this.status,
    required this.departureAirport,
    required this.departureIata,
    required this.arrivalAirport,
    required this.arrivalIata,
    this.departureTime,
    this.arrivalTime,
    this.gate,
    this.terminal,
    this.delayMinutes,
    this.aircraftModel,
    this.originCity,
    this.destinationCity,
    this.duration,
    this.distance,
    this.originLat,
    this.originLng,
    this.destLat,
    this.destLng,
  });

  final String? aircraftModel;
  final String? originCity;
  final String? destinationCity;
  final String? duration;
  final int? distance;
  final double? originLat;
  final double? originLng;
  final double? destLat;
  final double? destLng;
}

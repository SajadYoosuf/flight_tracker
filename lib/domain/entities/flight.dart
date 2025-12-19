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
  });
}

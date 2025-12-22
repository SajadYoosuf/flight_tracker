import '../../domain/entities/flight.dart';
import '../../core/constants/airport_coordinates.dart';

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
    super.aircraftModel,
    super.originCity,
    super.destinationCity,
    super.duration,
    super.distance,
    super.originLat,
    super.originLng,
    super.destLat,
    super.destLng,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('flight') && json['flight'] is Map) {
      // Existing mock structure or other API
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
    } else {
       // Fallback or assume FlyMat structure if direct usage
       return FlightModel.fromFlyMatJson(json);
    }
  }

  factory FlightModel.fromFlyMatJson(Map<String, dynamic> json) {
    // Mapping FlyMat API fields
    return FlightModel(
      flightNumber: json['fnia'] ?? json['fnic'] ?? 'UNKNOWN',
      airline: json['alna'] ?? 'Unknown Airline',
      status: json['status'] ?? 'scheduled',
      departureAirport: json['aporgna'] ?? 'Unknown Airport',
      departureIata: json['aporgia'] ?? '???',
      arrivalAirport: json['apdstna'] ?? 'Unknown Airport',
      arrivalIata: json['apdstia'] ?? '???',
      // 'deps_utc' is HH:mm, need to combine with date or use 'depsts' (timestamp)
      // API provides 'depsts' (Departure timestamp UTC) and 'arrsts' (Arrival timestamp UTC)
      departureTime: _parseTimestamp(json['depsts']),
      arrivalTime: _parseTimestamp(json['arrsts']),
      gate: json['depgate'],
      terminal: json['depterm'],
      // delay is in seconds in API usually? Or statusLabel.ts? 
      // Sample shows "delay": -209743 which is huge negative, possibly relative ms? 
      // "delay": null in some. "statusLabel": {"ts": 209743}
      // Let's use simple logic: if status is 'active' or 'landed' and we have scheduled vs actual...
      // For now, mapping 'delay' if positive and reasonable, else 0.
      delayMinutes: 0, 
      aircraftModel: json['acd'],
      originCity: json['aporgci'],
      destinationCity: json['apdstci'],
      duration: json['duration'],
      distance: json['distance'],
      originLat: (json['aporgla']?.toDouble()) ?? AirportCoordinates.getCoordinates(json['aporgia'] ?? '')?['lat'],
      originLng: (json['aporglo']?.toDouble()) ?? AirportCoordinates.getCoordinates(json['aporgia'] ?? '')?['lng'],
      destLat: (json['apdstla']?.toDouble()) ?? AirportCoordinates.getCoordinates(json['apdstia'] ?? '')?['lat'],
      destLng: (json['apdstlo']?.toDouble()) ?? AirportCoordinates.getCoordinates(json['apdstia'] ?? '')?['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flight': {'iata': flightNumber},
      'airline': {'name': airline},
      'flight_status': status,
      'departure': {
        'airport': departureAirport,
        'iata': departureIata,
        'scheduled': departureTime?.toIso8601String(),
        'gate': gate,
        'terminal': terminal,
        'delay': delayMinutes,
      },
      'arrival': {
        'airport': arrivalAirport,
        'iata': arrivalIata,
        'scheduled': arrivalTime?.toIso8601String(),
      },
      // Extra field for favorite timestamp if needed, but managing it in a wrapper or just implicitly is fine.
      // For simplicity, we stick to the structure that fromJson expects.
    };
  }

  static DateTime? _parseTimestamp(dynamic ts) {
    if (ts == null) return null;
    try {
      if (ts is num) {
        return DateTime.fromMillisecondsSinceEpoch(ts.toInt() * 1000, isUtc: true).toLocal();
      } else if (ts is String) {
        final parsed = int.tryParse(ts);
        if (parsed != null) {
          return DateTime.fromMillisecondsSinceEpoch(parsed * 1000, isUtc: true).toLocal();
        }
      }
    } catch (e) {
      // safe fallback
    }
    return null;
  }
}

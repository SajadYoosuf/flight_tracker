import '../models/flight_model.dart';
import 'dart:convert';

abstract class FlightRemoteDataSource {
  Future<List<FlightModel>> getFlights();
  Future<List<FlightModel>> searchFlights(String query);
}

class FlightRemoteDataSourceImpl implements FlightRemoteDataSource {
  // Simulating API call
  @override
  Future<List<FlightModel>> getFlights() async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Network delay
    
    // Mock Data simulating AviationStack response structure
    final List<Map<String, dynamic>> mockData = [
      {
        "flight_status": "active",
        "departure": {
          "airport": "San Francisco International",
          "timezone": "America/Los_Angeles",
          "iata": "SFO",
          "icao": "KSFO",
          "terminal": "2",
          "gate": "D11",
          "delay": 15,
          "scheduled": "2024-12-19T10:00:00+00:00",
          "estimated": "2024-12-19T10:15:00+00:00",
          "actual": "2024-12-19T10:14:00+00:00",
          "estimated_runway": "2024-12-19T10:14:00+00:00",
          "actual_runway": "2024-12-19T10:14:00+00:00"
        },
        "arrival": {
          "airport": "Dallas/Fort Worth International",
          "timezone": "America/Chicago",
          "iata": "DFW",
          "icao": "KDFW",
          "terminal": "A",
          "gate": "A22",
          "baggage": "A17",
          "delay": null,
          "scheduled": "2024-12-19T15:30:00+00:00",
          "estimated": "2024-12-19T15:30:00+00:00",
          "actual": null,
          "estimated_runway": null,
          "actual_runway": null
        },
        "airline": {
          "name": "American Airlines",
          "iata": "AA",
          "icao": "AAL"
        },
        "flight": {
          "number": "1004",
          "iata": "AA1004",
          "icao": "AAL1004",
          "codeshared": null
        },
      },
       {
        "flight_status": "scheduled",
        "departure": {
          "airport": "John F Kennedy International",
          "timezone": "America/New_York",
          "iata": "JFK",
          "icao": "KJFK",
          "terminal": "8",
          "gate": "31",
          "delay": null,
          "scheduled": "2024-12-19T14:00:00+00:00"
        },
        "arrival": {
          "airport": "Heathrow",
          "timezone": "Europe/London",
          "iata": "LHR",
          "icao": "EGLL",
          "terminal": "5",
          "gate": null,
          "scheduled": "2024-12-20T06:00:00+00:00"
        },
        "airline": {
          "name": "British Airways",
          "iata": "BA",
          "icao": "BAW"
        },
        "flight": {
          "number": "112",
          "iata": "BA112",
          "icao": "BAW112"
        },
      },
      {
        "flight_status": "landed",
        "departure": {
          "airport": "Dubai International",
          "timezone": "Asia/Dubai",
          "iata": "DXB",
          "icao": "OMDB",
          "terminal": "3",
          "gate": "A6",
          "scheduled": "2024-12-19T02:00:00+00:00"
        },
        "arrival": {
          "airport": "Singapore Changi",
          "timezone": "Asia/Singapore",
          "iata": "SIN",
          "icao": "WSSS",
          "terminal": "3",
          "gate": null,
          "scheduled": "2024-12-19T13:30:00+00:00"
        },
        "airline": {
          "name": "Emirates",
          "iata": "EK",
          "icao": "UAE"
        },
        "flight": {
          "number": "354",
          "iata": "EK354",
          "icao": "UAE354"
        },
      }
    ];

    return mockData.map((e) => FlightModel.fromJson(e)).toList();
  }

  @override
  Future<List<FlightModel>> searchFlights(String query) async {
    // Basic local filter of the mock data
    final allFlights = await getFlights();
    return allFlights.where((flight) {
      final q = query.toLowerCase();
      return flight.flightNumber.toLowerCase().contains(q) ||
             flight.departureAirport.toLowerCase().contains(q) ||
             flight.arrivalAirport.toLowerCase().contains(q) ||
             flight.departureIata.toLowerCase().contains(q) ||
             flight.arrivalIata.toLowerCase().contains(q);
    }).toList();
  }
}

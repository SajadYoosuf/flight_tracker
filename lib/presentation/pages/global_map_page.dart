import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../providers/flight_provider.dart';
import '../../domain/entities/flight.dart';

class GlobalMapPage extends StatefulWidget {
  const GlobalMapPage({super.key});

  @override
  State<GlobalMapPage> createState() => _GlobalMapPageState();
}

class _GlobalMapPageState extends State<GlobalMapPage> {
  late final Timer _timer;
  Map<String, LatLng> _flightPositions = {};

  @override
  void initState() {
    super.initState();
    // Load flight data if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<FlightProvider>().flights.isEmpty) {
        context.read<FlightProvider>().loadFlights();
      }
    });

    // Animation loop for interpolation
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _updateFlightPositions();
    });
  }

  void _updateFlightPositions() {
    final flights = context.read<FlightProvider>().flights;
    final now = DateTime.now();
    final newPositions = <String, LatLng>{};

    for (var flight in flights) {
      if (flight.originLat != null && flight.originLng != null &&
          flight.destLat != null && flight.destLng != null &&
          flight.departureTime != null && flight.arrivalTime != null) {
        
        // Calculate progress
        final totalDuration = flight.arrivalTime!.difference(flight.departureTime!).inSeconds;
        final elapsed = now.difference(flight.departureTime!).inSeconds;
        
        double progress = 0.0;
        if (totalDuration > 0) {
           progress = elapsed / totalDuration;
        }

        // Clamp progress to keep it visible on route or arrived
        if (progress < 0) progress = 0;
        if (progress > 1) progress = 1;

        // Linear interpolation
        final lat = flight.originLat! + (flight.destLat! - flight.originLat!) * progress;
        final lng = flight.originLng! + (flight.destLng! - flight.originLng!) * progress;
        
        newPositions[flight.flightNumber] = LatLng(lat, lng);
      }
    }

    if (mounted) {
      setState(() {
        _flightPositions = newPositions;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Center map roughly around India/Middle East or user location
    // Using a broad view for now
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(20.0, 78.0), // Center on India
              initialZoom: 4.0,
              minZoom: 2.0,
            ),
            children: [
              // Dark Matter Tiles for modern look
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.example.flight_tracker',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              // Aircraft Markers
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
          
          // Header / Stats Card
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.black.withOpacity(0.7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Consumer<FlightProvider>(
                    builder: (context, provider, child) {
                       return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           const Text(
                            "LIVE AIR TRAFFIC",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary, // Keeping orange/accent
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_flightPositions.length} Active Flights",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final flights = context.read<FlightProvider>().flights;
    List<Marker> markers = [];

    for (var flight in flights) {
       final pos = _flightPositions[flight.flightNumber];
       if (pos != null) {
          // Calculate heading
          double heading = 0;
          if (flight.originLat != null && flight.originLng != null &&
              flight.destLat != null && flight.destLng != null) {
             // Simple bearing for demo - calculate true bearing if needed
             final dLon = (flight.destLng! - flight.originLng!); 
             final y = dLon; 
             final x = (flight.destLat! - flight.originLat!);
             // Use math.atan from dart:math
             heading = (x != 0 || y != 0) ? (math.pi / 2) - math.atan(x / y) : 0; 
          }
           
          markers.add(
            Marker(
              point: pos,
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showFlightPopup(context, flight),
                child: Transform.rotate(
                  angle: heading,
                  child: const Icon(
                    Icons.airplanemode_active,
                    color: AppColors.primary, // Make sure this stands out on dark map
                    size: 24,
                  ),
                ),
              ),
            ),
          );
       }
    }
    return markers;
  }

  void _showFlightPopup(BuildContext context, Flight flight) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
           padding: const EdgeInsets.all(20),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(20),
           ),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(flight.originCity ?? flight.departureIata, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Icon(Icons.flight_takeoff, color: AppColors.primary),
                    Text(flight.destinationCity ?? flight.arrivalIata, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(flight.airline, style: const TextStyle(color: Colors.grey)),
                Text(flight.flightNumber, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      // Optionally nav to details
                    },
                    child: const Text("Close", style: TextStyle(color: Colors.white)),
                  ),
                )
             ],
           ),
        ),
      ),
    );
  }
}

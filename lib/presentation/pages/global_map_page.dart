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
  Timer? _timer;
  Map<String, LatLng> _flightPositions = {};
  Map<String, double> _flightBearings = {};

  @override
  void initState() {
    super.initState();
    // Load flight data if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<FlightProvider>().flights.isEmpty) {
        context.read<FlightProvider>().loadFlights();
      }
    });

    // High frequency timer for smooth animation (30 fps approx)
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _updateFlightPositions();
    });
  }

  void _updateFlightPositions() {
    final flights = context.read<FlightProvider>().flights;
    final now = DateTime.now();
    final newPositions = <String, LatLng>{};
    final newBearings = <String, double>{};

    for (var flight in flights) {
      if (flight.originLat != null && flight.originLng != null &&
          flight.destLat != null && flight.destLng != null &&
          flight.departureTime != null && flight.arrivalTime != null) {
        
        final start = flight.departureTime!;
        final end = flight.arrivalTime!;
        final totalDuration = end.difference(start).inMilliseconds;
        final elapsed = now.difference(start).inMilliseconds;
        
        double progress = 0.0;
        if (totalDuration > 0) {
           progress = elapsed / totalDuration;
        }

        // Clamp to 0-1 range to keep flight on path even if simulated time is weird
        // Or if we want to show 'arrived' flights at dest, clamp to 1.
        if (progress < 0) progress = 0;
        if (progress > 1) progress = 1;

        // Linear interpolation for simple movement
        // For more accuracy on global scale, intermediate points on Great Circle are better,
        // but linear on LatLng is sufficient for visual approximation here.
        final lat = flight.originLat! + (flight.destLat! - flight.originLat!) * progress;
        final lng = flight.originLng! + (flight.destLng! - flight.originLng!) * progress;
        
        newPositions[flight.flightNumber] = LatLng(lat, lng);
        
        // Calculate bearing between origin and destination (constant for linear path)
        // Or between current and destination for dynamic adjustment
        newBearings[flight.flightNumber] = _calculateBearing(
           flight.originLat!, flight.originLng!, flight.destLat!, flight.destLng!
        );
      }
    }

    if (mounted) {
      setState(() {
        _flightPositions = newPositions;
        _flightBearings = newBearings;
      });
    }
  }
  
  // Calculates bearing in radians
  double _calculateBearing(double startLat, double startLng, double endLat, double endLng) {
    final lat1 = startLat * math.pi / 180;
    final lat2 = endLat * math.pi / 180;
    final dLng = (endLng - startLng) * math.pi / 180;

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
              math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    
    // atan2 returns -pi to pi.
    // Convert to 0-360 degrees then to radians for Transform.rotate usually? 
    // Transform.rotate takes radians. atan2 is already radians.
    // However, 0 is East in standard math, but North in Map bearings.
    // Standard bearing formula: theta = atan2(X, Y)
    // Here we need to align with Icon rotation.
    // Usually icons face up (North). We need clockwise rotation from North.
    
    return math.atan2(y, x);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(22.0, 78.0), // Center on India
              initialZoom: 4.5,
              minZoom: 2.0,
            ),
            children: [
              TileLayer(
                // Using CartoDB Positron for clean light look
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.example.flight_tracker',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.black.withOpacity(0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Consumer<FlightProvider>(
                    builder: (context, provider, child) {
                       final activeCount = _flightPositions.length;
                       return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           const Text(
                            "LIVE AIR TRAFFIC",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$activeCount Active Flights",
                            style: const TextStyle(
                              fontSize: 18,
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
       final bearing = _flightBearings[flight.flightNumber] ?? 0.0;
       
       if (pos != null) {
          markers.add(
            Marker(
              point: pos,
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showFlightPopup(context, flight),
                // Plane icon usually faces UP (0 degrees). 
                // Bearing is clockwise from North in navigation, 
                // but atan2(y, x) results in counter-clockwise from East?
                // Let's use simple Transform.rotate(angle: bearing - pi/2) adjustment if needed.
                // Actually with the formula atan2(sin(dL)*cos(l2), cos(l1)*sin(l2)-...)
                // Result is clockwise from North in radians. Perfect for map rotation.
                // However verifying icon orientation: Icons.airplanemode_active points UP.
                child: Transform.rotate(
                  angle: bearing, 
                  child: const Icon(
                    Icons.airplanemode_active,
                    color: AppColors.primary,
                    size: 28,
                    shadows: [
                      Shadow(blurRadius: 10, color: AppColors.secondary, offset: Offset(0,0))
                    ],
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

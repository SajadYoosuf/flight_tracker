import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/colors.dart';

class GlobalMapPage extends StatefulWidget {
  const GlobalMapPage({super.key});

  @override
  State<GlobalMapPage> createState() => _GlobalMapPageState();
}

class _GlobalMapPageState extends State<GlobalMapPage> {
  // Simulated flight positions
  List<LatLng> _flightPositions = [
    const LatLng(51.509364, -0.128928), // London
    const LatLng(40.712776, -74.005974), // New York
    const LatLng(48.856613, 2.352222), // Paris
    const LatLng(35.689487, 139.691711), // Tokyo
    const LatLng(25.204849, 55.270783), // Dubai
    const LatLng(1.352083, 103.819836), // Singapore
  ];

  // Flight directions (lat/lng deltas)
  final List<List<double>> _flightDirections = [
    [0.1, 0.1],
    [-0.1, 0.05],
    [0.05, -0.1],
    [-0.05, -0.05],
    [0.08, 0.08],
    [-0.08, 0.02],
  ];

  late final Timer _timer; // Use dart:async Timer

  @override
  void initState() {
    super.initState();
    // Start animation loop
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        for (int i = 0; i < _flightPositions.length; i++) {
          double newLat = _flightPositions[i].latitude + _flightDirections[i][0];
          double newLng = _flightPositions[i].longitude + _flightDirections[i][1];
          
          // Simple bounce logic to keep them somewhat in view or just wrap around
          if (newLat > 90 || newLat < -90) _flightDirections[i][0] *= -1;
          if (newLng > 180 || newLng < -180) _flightDirections[i][1] *= -1;
          
           _flightPositions[i] = LatLng(newLat, newLng);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(25.204849, 55.270783), // Center on Dubai
              initialZoom: 2.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flight_tracker',
              ),
              MarkerLayer(
                markers: _flightPositions.asMap().entries.map((entry) {
                  int idx = entry.key;
                  LatLng pos = entry.value;
                  return Marker(
                    point: pos,
                    width: 40,
                    height: 40,
                    child: Transform.rotate(
                      // fast calculation of angle based on direction
                       angle: 0, // Simplified for now
                      child: const Icon(
                        Icons.airplanemode_active,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withValues(alpha: 0.9),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text(
                        "Global Flight View",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                       Text(
                        "${_flightPositions.length} Active Flights",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

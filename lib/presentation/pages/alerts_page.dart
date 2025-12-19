import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../providers/flight_provider.dart';
import '../../domain/entities/flight.dart';
import '../../core/constants/colors.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Flight Alerts',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<FlightProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
             return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.flights.isEmpty) {
             return const Center(child: Text("No alerts available"));
          }

          // Generate alerts from real flight data
          final alerts = _generateAlerts(provider.flights);

          if (alerts.isEmpty) {
             return const Center(child: Text("No active alerts"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return FadeInLeft(
                delay: Duration(milliseconds: 100 * index),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getAlertColor(alert['type']).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getAlertIcon(alert['type']),
                          color: _getAlertColor(alert['type']),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    alert['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  alert['time'],
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alert['message'],
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _generateAlerts(List<Flight> flights) {
    List<Map<String, dynamic>> generatedAlerts = [];
    
    for (var flight in flights) {
       final status = flight.status.toLowerCase();
       
       // Departure Alerts (Active flights)
       if (['active', 'started', 'en-route', 'departed'].contains(status)) {
          generatedAlerts.add({
            'title': 'Flight ${flight.flightNumber} Departed',
            'message': '${flight.airline} flight to ${flight.arrivalAirport} has departed.',
            'time': 'Active',
            'type': 'departure',
          });
       }
       
       // Delay Alerts
       if (flight.delayMinutes != null && flight.delayMinutes! > 0) {
          generatedAlerts.add({
             'title': 'Flight ${flight.flightNumber} Delayed',
             'message': 'Delayed by ${flight.delayMinutes} minutes.',
             'time': 'Delayed',
             'type': 'late',
          });
       }

       // Arrival status
       if (status == 'landed') {
          generatedAlerts.add({
             'title': 'Flight ${flight.flightNumber} Arrived',
             'message': 'Arrived at ${flight.arrivalAirport}.',
             'time': 'Landed',
             'type': 'arrival',
          });
       }
    }
    return generatedAlerts;
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'departure':
        return AppColors.primary;
      case 'arrival':
        return AppColors.success;
      case 'late':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'departure':
        return Icons.flight_takeoff;
      case 'arrival':
        return Icons.flight_land;
      case 'late':
        return Icons.access_time_filled;
      default:
        return Icons.info_outline;
    }
  }
}

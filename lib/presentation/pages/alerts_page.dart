import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated alerts data
    final List<Map<String, dynamic>> alerts = [
      {
        'title': 'Flight AA123 Departure',
        'message': 'Flight AA123 has departed from JFK.',
        'time': '10 min ago',
        'type': 'departure',
      },
      {
        'title': 'Flight BA456 Delay',
        'message': 'Flight BA456 is delayed by 45 minutes.',
        'time': '25 min ago',
        'type': 'late',
      },
      {
        'title': 'Flight EK789 Arrival',
        'message': 'Flight EK789 has arrived at DXB.',
        'time': '1 hour ago',
        'type': 'arrival',
      },
       {
        'title': 'Gate Change SQ321',
        'message': 'Gate changed to A12.',
        'time': '2 hours ago',
        'type': 'info',
      },
    ];

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
      body: ListView.separated(
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
                            Text(
                              alert['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
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
      ),
    );
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

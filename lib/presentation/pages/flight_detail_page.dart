import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/entities/flight.dart';
import '../../core/constants/colors.dart';

class FlightDetailPage extends StatelessWidget {
  final Flight flight;

  const FlightDetailPage({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Flight Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favorites')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Map Placeholder
          Expanded(
            flex: 2,
            child: Container(
               width: double.infinity,
               margin: const EdgeInsets.symmetric(horizontal: 24),
               decoration: BoxDecoration(
                 color: Colors.white.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(24),
                 border: Border.all(color: Colors.white.withOpacity(0.2)),
               ),
               child: const Center(
                 child: Icon(Icons.map, size: 60, color: Colors.white30),
               ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flight.airline,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                flight.flightNumber,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              flight.status.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeInLeft(
                      child: Row(
                        children: [
                          _buildDetailItem(
                            'Departure', 
                            flight.departureIata,
                            flight.departureAirport,
                            flight.departureTime,
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                          const Spacer(),
                           _buildDetailItem(
                            'Arrival', 
                            flight.arrivalIata,
                            flight.arrivalAirport,
                            flight.arrivalTime,
                            alignment: CrossAxisAlignment.end,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoBox('Gate', flight.gate ?? '-'),
                          _buildInfoBox('Terminal', flight.terminal ?? '-'),
                          _buildInfoBox('Delay', flight.delayMinutes != null ? '${flight.delayMinutes}m' : 'On Time',
                              isAlert: (flight.delayMinutes ?? 0) > 0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Notification logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Get Notifications', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String code, String airport, DateTime? time, {CrossAxisAlignment alignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text(
          code,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 120,
          child: Text(
            airport, 
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
            textAlign: alignment == CrossAxisAlignment.end ? TextAlign.right : TextAlign.left,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          time != null ? DateFormat('HH:mm').format(time) : '--:--',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
         Text(
          time != null ? DateFormat('MMM dd').format(time) : '',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String label, String value, {bool isAlert = false}) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? AppColors.error.withOpacity(0.1) : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(
            value, 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              color: isAlert ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

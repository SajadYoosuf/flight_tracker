import 'package:flutter/material.dart';
import '../../domain/entities/flight.dart';
import '../../core/constants/colors.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'package:intl/intl.dart';

class FlightDetailPage extends StatelessWidget {
  final Flight flight;

  const FlightDetailPage({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    // Helper to format duration string if needed
    String displayDuration = flight.duration ?? '--';
    
    // Helper for city names
    String originCity = flight.originCity ?? flight.departureAirport;
    String destCity = flight.destinationCity ?? flight.arrivalAirport;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
               Consumer<FavoritesProvider>(
                builder: (context, favoritesProvider, child) {
                  final isFavorite = favoritesProvider.isFavorite(flight.flightNumber);
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      favoritesProvider.toggleFavorite(flight);
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text(isFavorite ? 'Removed from favorites' : 'Added to favorites')),
                      );
                    },
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, Color(0xFF1E3C72)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const SizedBox(height: 40),
                       Text(
                         flight.airline,
                         style: const TextStyle(
                           color: Colors.white70,
                           fontSize: 16,
                           fontWeight: FontWeight.w500
                         ),
                       ),
                       const SizedBox(height: 8),
                       Text(
                         flight.flightNumber,
                         style: const TextStyle(
                           color: Colors.white,
                           fontSize: 34,
                           fontWeight: FontWeight.bold,
                           letterSpacing: 1.2
                         ),
                       ),
                       const SizedBox(height: 16),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.2),
                           borderRadius: BorderRadius.circular(20),
                         ),
                         child: Text(
                           flight.status.toUpperCase(),
                           style: const TextStyle(
                             color: Colors.white,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       )
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                   // Route Card
                   _buildRouteCard(context, dateFormat, timeFormat, originCity, destCity, displayDuration),
                   const SizedBox(height: 20),
                   // Details Grid (Aircraft, Terminal, etc)
                   _buildDetailsGrid(),
                   const SizedBox(height: 20),
                   // Timings Card
                   _buildTimingsCard(timeFormat),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, DateFormat dateFormat, DateFormat timeFormat, String origin, String dest, String duration) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildAirportInfo(flight.departureIata, origin, CrossAxisAlignment.start)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                     Icon(Icons.flight_takeoff, color: AppColors.textSecondary.withOpacity(0.3), size: 24),
                     const SizedBox(height: 4),
                     Text(
                       duration,
                       style: const TextStyle(
                         fontSize: 12,
                         fontWeight: FontWeight.bold,
                         color: AppColors.textSecondary
                       ),
                     )
                  ],
                ),
              ),
              Expanded(child: _buildAirportInfo(flight.arrivalIata, dest, CrossAxisAlignment.end)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateTimeInfo(flight.departureTime, dateFormat, timeFormat, CrossAxisAlignment.start),
              _buildDateTimeInfo(flight.arrivalTime, dateFormat, timeFormat, CrossAxisAlignment.end),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAirportInfo(String code, String name, CrossAxisAlignment align) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          code,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: align == CrossAxisAlignment.end ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildDateTimeInfo(DateTime? date, DateFormat dF, DateFormat tF, CrossAxisAlignment align) {
     if (date == null) {
       return Column(
         crossAxisAlignment: align,
         children: const [
           Text("--:--", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
           Text("", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
         ],
       );
     }
     return Column(
       crossAxisAlignment: align,
       children: [
          Text(tF.format(date), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(dF.format(date), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
       ],
     );
  }

  Widget _buildDetailsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildInfoCard(Icons.airplanemode_active, 'Aircraft', flight.aircraftModel ?? 'Unknown'),
        _buildInfoCard(Icons.straighten, 'Distance', flight.distance != null ? '${(flight.distance! / 1000).toStringAsFixed(0)} km' : 'Unknown'),
        _buildInfoCard(Icons.meeting_room, 'Gate', flight.gate ?? '--'),
        _buildInfoCard(Icons.domain, 'Terminal', flight.terminal ?? '--'),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.03),
             blurRadius: 10,
             offset: const Offset(0, 4)
           )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Icon(icon, color: AppColors.primary, size: 28),
           const Spacer(),
           Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
           const SizedBox(height: 4),
           Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTimingsCard(DateFormat timeFormat) {
     return Container(
       padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
         color: AppColors.secondary.withOpacity(0.1),
         borderRadius: BorderRadius.circular(24),
       ),
       child: Row(
         children: [
            const Icon(Icons.info_outline, color: AppColors.secondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Flight status is ${flight.status}. Last updated ${timeFormat.format(DateTime.now())}.',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              ),
            )
         ],
       ),
     );
  }
}

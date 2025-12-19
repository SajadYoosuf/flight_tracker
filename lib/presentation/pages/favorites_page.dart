import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../providers/favorites_provider.dart';
import '../widgets/flight_card.dart';
import 'flight_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          if (provider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.favorite_border, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No favorites yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: provider.favorites.length,
            itemBuilder: (context, index) {
              final flight = provider.favorites[index];
              final timestamp = provider.timestamps[flight.flightNumber];

              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: Column(
                  children: [
                    if (timestamp != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Favorited at: ${DateFormat('MMM dd, HH:mm').format(timestamp)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    FlightCard(
                      flight: flight,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FlightDetailPage(flight: flight),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

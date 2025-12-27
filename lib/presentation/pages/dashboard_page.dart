import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/colors.dart';
import '../providers/flight_provider.dart';
import '../widgets/flight_card.dart';
import 'flight_detail_page.dart';
import 'favorites_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FlightProvider>();
      if (provider.flights.isEmpty) {
        provider.loadFlights();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hello Traveler 👋',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              IconButton(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FavoritesPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.favorite, color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Find Your Flight',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            onChanged: (value) {
               context.read<FlightProvider>().searchFlights(value);
            },
            decoration: InputDecoration(
              hintText: 'Search flight number, route...',
              prefixIcon: const Icon(Icons.search),
            
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<FlightProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingList();
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        if (provider.flights.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.airplanemode_off, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('No flights found', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: provider.flights.length,
          itemBuilder: (context, index) {
            final flight = provider.flights[index];
            return FadeInUp(
              delay: Duration(milliseconds: 100 * index),
              child: FlightCard(
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
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}

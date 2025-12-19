import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/flight_remote_data_source.dart';
import 'data/repositories/flight_repository_impl.dart';
import 'presentation/providers/flight_provider.dart';
import 'presentation/pages/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection
    final flightRemoteDataSource = FlightRemoteDataSourceImpl();
    final flightRepository = FlightRepositoryImpl(remoteDataSource: flightRemoteDataSource);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FlightProvider(repository: flightRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Flight Tracker',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

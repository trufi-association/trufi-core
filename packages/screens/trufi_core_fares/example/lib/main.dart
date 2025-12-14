import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trufi_core_fares/trufi_core_fares.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = FaresTrufiScreen(
      config: FaresConfig(
        currency: 'Bs.',
        lastUpdated: DateTime(2024, 1, 15),
        additionalNotes:
            'Fares may vary depending on the route and time of day. Children under 5 ride free.',
        externalFareUrl: 'https://example.com/fares',
        fares: [
          const FareInfo(
            transportType: 'Trufi',
            icon: Icons.directions_bus,
            regularFare: '2.00',
            studentFare: '1.50',
            seniorFare: '1.00',
            notes: 'Valid for urban routes within the city center',
          ),
          const FareInfo(
            transportType: 'Micro',
            icon: Icons.airport_shuttle,
            regularFare: '1.50',
            studentFare: '1.00',
            seniorFare: '0.75',
          ),
          const FareInfo(
            transportType: 'Minibus',
            icon: Icons.directions_bus_filled,
            regularFare: '2.50',
            studentFare: '2.00',
            notes: 'Covers longer routes to peripheral areas',
          ),
        ],
      ),
    );

    return MaterialApp(
      title: 'Fares Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Scaffold(body: Builder(builder: screen.builder)),
      localizationsDelegates: [
        ...screen.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: screen.supportedLocales,
    );
  }
}

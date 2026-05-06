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
            'Fares may vary depending on the route and time of day. '
            'Children under 5 ride free.',
        externalFareUrl: 'https://example.com/fares',
        fares: const [
          FareInfo(
            title: 'Trufi',
            icon: Icons.directions_bus,
            primary: FareCategory(
              label: 'Regular',
              price: '2.00',
              icon: Icons.person_rounded,
            ),
            additional: [
              FareCategory(
                label: 'Student',
                price: '1.50',
                icon: Icons.school_rounded,
              ),
              FareCategory(
                label: 'Senior',
                price: '1.00',
                icon: Icons.elderly_rounded,
              ),
            ],
            notes: 'Valid for urban routes within the city center',
          ),
          FareInfo(
            title: 'Micro',
            icon: Icons.airport_shuttle,
            primary: FareCategory(
              label: 'Regular',
              price: '1.50',
              icon: Icons.person_rounded,
            ),
            additional: [
              FareCategory(
                label: 'Student',
                price: '1.00',
                icon: Icons.school_rounded,
              ),
              FareCategory(
                label: 'Senior',
                price: '0.75',
                icon: Icons.elderly_rounded,
              ),
            ],
          ),
          FareInfo(
            title: 'Minibus',
            icon: Icons.directions_bus_filled,
            primary: FareCategory(
              label: 'Regular',
              price: '2.50',
              icon: Icons.person_rounded,
            ),
            additional: [
              FareCategory(
                label: 'Student',
                price: '2.00',
                icon: Icons.school_rounded,
              ),
            ],
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

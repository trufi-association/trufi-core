import 'package:flutter/material.dart';
import 'package:trufi_core_about/trufi_core_about.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final aboutScreen = AboutTrufiScreen(
      config: const AboutScreenConfig(
        appName: 'Trufi App',
        cityName: 'Cochabamba',
        countryName: 'Bolivia',
        emailContact: 'info@trufi-association.org',
        websiteUrl: 'https://www.trufi-association.org',
      ),
    );

    return MaterialApp(
      title: 'About Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('de'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...aboutScreen.localizationsDelegates,
      ],
      home: Scaffold(body: Builder(builder: aboutScreen.builder)),
    );
  }
}

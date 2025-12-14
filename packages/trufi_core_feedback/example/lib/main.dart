import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trufi_core_feedback/trufi_core_feedback.dart';

void main() {
  runApp(const FeedbackExampleApp());
}

class FeedbackExampleApp extends StatelessWidget {
  const FeedbackExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = FeedbackTrufiScreen(
      config: FeedbackConfig(
        feedbackUrl: 'https://example.com/feedback',
        getCurrentLocation: () async {
          // Simulate getting location
          return (-17.3988, -66.1627);
        },
      ),
    );

    return MaterialApp(
      title: 'Feedback Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(screen.getLocalizedTitle(context)),
        ),
        body: Builder(builder: screen.builder),
      ),
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

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';
import 'package:trufi_core_settings/trufi_core_settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = SettingsTrufiScreen();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocaleManager(defaultLocale: const Locale('en')),
        ),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: Consumer2<LocaleManager, ThemeManager>(
        builder: (context, localeManager, themeManager, _) {
          return MaterialApp(
            title: 'Settings Example',
            debugShowCheckedModeBanner: false,
            locale: localeManager.currentLocale,
            themeMode: themeManager.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
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
              ...screen.localizationsDelegates,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(body: Builder(builder: screen.builder)),
          );
        },
      ),
    );
  }
}

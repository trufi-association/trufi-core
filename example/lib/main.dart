import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:trufi_core/trufi_app.dart';
import 'package:trufi_core/trufi_initialization.dart';

void main() {
  initializeTrufiApp(
    initialize: () async {
      // Initialize locale
      const String appLocale = 'en';
      Intl.defaultLocale = appLocale;
      await initializeDateFormatting(appLocale);
    },
    onInitialized: (context) => const TrufiApp(
      title: 'Kigali Mobility',
      appName: 'Kigali Mobility',
      cityName: 'Kigali',
      urlRepository: 'https://github.com/trufi-association/trufi_core',
      urlFeedback: 'https://www.trufi-association.org/',
    ),
  );
}

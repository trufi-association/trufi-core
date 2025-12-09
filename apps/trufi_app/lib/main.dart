import 'package:trufi_core_about/trufi_core_about.dart';

import 'core/trufi_app.dart';

import 'features/feedback/feedback_screen.dart';
import 'features/home/home_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';

void main() {
  runTrufiApp(
    AppConfiguration(
      appName: 'Trufi App',
      screens: [
        HomeTrufiScreen(),
        SearchTrufiScreen(),
        FeedbackTrufiScreen(),
        SettingsTrufiScreen(),
        AboutTrufiScreen(
          config: AboutScreenConfig(
            appName: 'Trufi App',
            cityName: 'Cochabamba',
            countryName: 'Bolivia',
            emailContact: 'info@trufi-association.org',
          ),
        ),
      ],
    ),
  );
}

import 'core/trufi_app.dart';

import 'features/about/about_screen.dart';
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
        AboutTrufiScreen(),
      ],
    ),
  );
}

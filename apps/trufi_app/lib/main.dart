import 'package:latlong2/latlong.dart';
import 'package:trufi_core_about/trufi_core_about.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

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
        SavedPlacesTrufiScreen(
          config: SavedPlacesConfig(
            defaultLatitude: -17.3988354,
            defaultLongitude: -66.1626903,
          ),
        ),
        TransportListTrufiScreen(
          config: TransportListOtpConfig(
            otpEndpoint: 'https://otp-240.trufi-core.trufi.dev',
            defaultCenter: LatLng(-17.3988354, -66.1626903),
          ),
        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_about/trufi_core_about.dart';
import 'package:trufi_core_fares/trufi_core_fares.dart';
import 'package:trufi_core_feedback/trufi_core_feedback.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';
import 'package:trufi_core_settings/trufi_core_settings.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';
import 'package:trufi_core_ui/trufi_core_ui.dart';

const _defaultCenter = LatLng(-17.3988354, -66.1626903);

void main() {
  runTrufiApp(
    AppConfiguration(
      appName: 'Trufi App',
      socialMediaLinks: const [
        SocialMediaLink(
          url: 'https://facebook.com/trufiapp',
          icon: Icons.facebook,
          label: 'Facebook',
        ),
        SocialMediaLink(
          url: 'https://x.com/trufiapp',
          icon: Icons.close,
          label: 'X (Twitter)',
        ),
        SocialMediaLink(
          url: 'https://instagram.com/trufiapp',
          icon: Icons.camera_alt_outlined,
          label: 'Instagram',
        ),
      ],
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapEngineManager(
            engines: defaultMapEngines,
            defaultCenter: _defaultCenter,
          ),
        ),
        BlocProvider(
          create: (_) => SearchLocationsCubit(
            searchLocationService: PhotonSearchService(
              biasLatitude: _defaultCenter.latitude,
              biasLongitude: _defaultCenter.longitude,
            ),
          ),
        ),
      ],
      screens: [
        HomeScreenTrufiScreen(
          config: HomeScreenConfig(
            otpEndpoint: 'https://otp-240.trufi-core.trufi.dev',
          ),
          onStartNavigation: (context, itinerary, locationService) {
            NavigationScreen.showFromItinerary(
              context,
              itinerary: itinerary,
              locationService: locationService,
              mapEngineManager: MapEngineManager.read(context),
            );
          },
        ),
        SavedPlacesTrufiScreen(),
        TransportListTrufiScreen(
          config: TransportListOtpConfig(
            otpEndpoint: 'https://otp-240.trufi-core.trufi.dev',
          ),
        ),
        FaresTrufiScreen(
          config: FaresConfig(
            currency: 'Bs.',
            lastUpdated: DateTime(2024, 1, 15),
            fares: [
              const FareInfo(
                transportType: 'Trufi',
                icon: Icons.directions_bus,
                regularFare: '2.00',
                studentFare: '1.50',
                seniorFare: '1.00',
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
              ),
            ],
          ),
        ),
        FeedbackTrufiScreen(
          config: FeedbackConfig(
            feedbackUrl: 'https://www.trufi-association.org/feedback/',
          ),
        ),
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

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
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart'
    show OtpConfiguration, OtpVersion;
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';
import 'package:trufi_core_settings/trufi_core_settings.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';
import 'package:trufi_core_ui/trufi_core_ui.dart';

// ============ CONFIGURATION ============
const _otpConfiguration = OtpConfiguration(
  endpoint: 'https://otp.trufi.app',
  version: OtpVersion.v2_8,
);
const _photonUrl = 'https://photon.trufi.app';
const _defaultCenter = LatLng(-17.3988354, -66.1626903);
const _appName = 'Trufi App';
const _deepLinkScheme = 'trufiapp';
const _cityName = 'Cochabamba';
const _countryName = 'Bolivia';
const _emailContact = 'info@trufi-association.org';
const _feedbackUrl = 'https://www.trufi-association.org/feedback/';
const _facebookUrl = 'https://facebook.com/trufiapp';
const _xTwitterUrl = 'https://x.com/trufiapp';
const _instagramUrl = 'https://instagram.com/trufiapp';

const List<ITrufiMapEngine> _mapEngines = [
  MapLibreEngine(
    engineId: 'osm_bright',
    styleString: 'https://maps.trufi.app/styles/osm-bright/style.json',
    displayName: 'OSM Bright',
    displayDescription: 'Mapa claro',
  ),
  MapLibreEngine(
    engineId: 'osm_liberty',
    styleString: 'https://maps.trufi.app/styles/osm-liberty/style.json',
    displayName: 'OSM Liberty',
    displayDescription: 'Mapa estándar',
  ),
  MapLibreEngine(
    engineId: 'dark_matter',
    styleString: 'https://maps.trufi.app/styles/dark-matter/style.json',
    displayName: 'Dark Matter',
    displayDescription: 'Mapa oscuro',
  ),
  MapLibreEngine(
    engineId: 'fiord_color',
    styleString: 'https://maps.trufi.app/styles/fiord-color/style.json',
    displayName: 'Fiord Color',
    displayDescription: 'Mapa colorido',
  ),
];
// ========================================

void main() {
  runTrufiApp(
    AppConfiguration(
      appName: _appName,
      deepLinkScheme: _deepLinkScheme,
      defaultLocale: Locale('es'),
      appOverlayManagers: [
        OnboardingManager(
          overlayBuilder: (onComplete) =>
              OnboardingSheet(onComplete: onComplete),
        ),
        PrivacyConsentManager(
          overlayBuilder: (onAccept, onDecline) =>
              PrivacyConsentSheet(onAccept: onAccept, onDecline: onDecline),
        ),
      ],
      socialMediaLinks: const [
        SocialMediaLink(
          url: _facebookUrl,
          icon: Icons.facebook,
          label: 'Facebook',
        ),
        SocialMediaLink(
          url: _xTwitterUrl,
          icon: Icons.close,
          label: 'X (Twitter)',
        ),
        SocialMediaLink(
          url: _instagramUrl,
          icon: Icons.camera_alt_outlined,
          label: 'Instagram',
        ),
      ],
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapEngineManager(
            engines: _mapEngines,
            defaultCenter: _defaultCenter,
          ),
        ),
        BlocProvider(
          create: (_) => SearchLocationsCubit(
            searchLocationService: PhotonSearchService(
              baseUrl: _photonUrl,
              biasLatitude: _defaultCenter.latitude,
              biasLongitude: _defaultCenter.longitude,
            ),
          ),
        ),
      ],
      screens: [
        HomeScreenTrufiScreen(
          config: HomeScreenConfig(
            otpConfiguration: _otpConfiguration,
            appName: _appName,
            deepLinkScheme: _deepLinkScheme,
            poiLayersManager: POILayersManager(assetsBasePath: 'assets/pois'),
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
          otpConfiguration: _otpConfiguration,
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
            feedbackUrl: _feedbackUrl,
          ),
        ),
        SettingsTrufiScreen(),
        AboutTrufiScreen(
          config: AboutScreenConfig(
            appName: _appName,
            cityName: _cityName,
            countryName: _countryName,
            emailContact: _emailContact,
          ),
        ),
      ],
    ),
  );
}

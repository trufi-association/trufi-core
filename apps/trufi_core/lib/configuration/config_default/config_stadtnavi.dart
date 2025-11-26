import 'package:trufi_core/configuration/config_default/config_default.dart';
import 'package:trufi_core/configuration/config_default/config_default/city_bike_config.dart';
import 'package:trufi_core/configuration/config_default/config_default/default_options.dart';
import 'package:trufi_core/configuration/config_default/config_default/default_settings.dart';
import 'package:trufi_core/configuration/config_default/config_default/transport_mode_config.dart';

final configStadtnavi = ConfigData(
  showBikeAndPublicItineraries: true,
  showBikeAndParkItineraries: true,
  optimize: 'TRIANGLE',
  suggestCarMinDistance: 800,
  suggestWalkMaxDistance: 3000,
  suggestBikeAndPublicMinDistance: 3000,
  suggestBikeAndParkMinDistance: 3000,
  defaultSettings: DefaultSettings(
    optimize: 'TRIANGLE',
    safetyFactor: 0.4,
    slopeFactor: 0.3,
    timeFactor: 0.3,
    walkReluctance: 3,
    walkBoardCost: 150,
  ),
  defaultOptions: DefaultOptions(walkSpeed: [0.83, 1.38, 1.94]),
  cityBike: CityBikeConfig(
    minZoomStopsNearYou: 10,
    showStationId: false,
    useSpacesAvailable: false,
    showCityBikes: true,
    operators: {
      "taxi": OperatorConfig(
        icon: "brand_taxi",
        name: {"de": "Taxi", "en": "Taxi"},
        colors: {"background": "#FFCD00"},
      ),
      "flinkster": OperatorConfig(
        icon: "brand_flinkster",
        name: {"de": "Flinkster", "en": "Flinkster"},
        url: {
          "de": "https://www.flinkster.de/de/start",
          "en": "https://www.flinkster.de/en/home",
        },
        colors: {"background": "#D50F0F"},
      ),
      "deer": OperatorConfig(
        icon: "brand_deer",
        name: {"de": "deer", "en": "deer"},
        url: {"de": "https://www.deer-carsharing.de/"},
        colors: {"background": "#3C8325"},
      ),
      "bolt": OperatorConfig(
        icon: "brand_bolt",
        name: {"de": "bolt", "en": "bolt"},
        colors: {"background": "#30D287"},
      ),
      "voi": OperatorConfig(
        icon: "brand_voi",
        name: {"de": "VOI", "en": "VOI"},
        colors: {"background": "#F26961"},
      ),
      "dott": OperatorConfig(
        icon: "brand_dott",
        name: {"de": "dott", "en": "dott"},
        colors: {"background": "#009DDB"},
      ),
      "regiorad": OperatorConfig(
        icon: "brand_regiorad",
        name: {"de": "RegioRad", "en": "RegioRad"},
        colors: {"background": "#009fe4"},
      ),
      "stadtmobil": OperatorConfig(
        icon: "brand_stadtmobil",
        name: {"de": "stadtmobil", "en": "stadtmobil"},
        colors: {"background": "#FF8A36"},
      ),
      "zeus": OperatorConfig(
        icon: "brand_zeus",
        name: {"de": "ZEUS Scooters", "en": "ZEUS Scooters"},
        colors: {"background": "#F75118"},
      ),
      "other": OperatorConfig(
        icon: "brand_other",
        name: {"de": "Weitere Anbieter", "en": "Other Operators"},
        colors: {"background": "#C84674"},
      ),
    },
    networks: {},
  ),
  transportModes: {
    "nearYouTitle": TransportModeConfig(
      nearYouLabel: {"de": "Fahrpläne und Routen"},
    ),
    "bus": TransportModeConfig(
      availableForSelection: true,
      defaultValue: true,
      smallIconZoom: 16,
      nearYouLabel: {"de": "Bushaltestellen in der Nähe"},
    ),
    "rail": TransportModeConfig(
      availableForSelection: true,
      defaultValue: true,
      nearYouLabel: {"de": "Bahnhaltestellen in der Nähe"},
    ),
    "tram": TransportModeConfig(
      availableForSelection: false,
      defaultValue: false,
      nearYouLabel: {"de": "Tramhaltestellen in der Nähe"},
    ),
    "subway": TransportModeConfig(
      availableForSelection: true,
      defaultValue: true,
      nearYouLabel: {"de": "U-Bahnhaltestellen in der Nähe"},
    ),
    "airplane": TransportModeConfig(
      availableForSelection: false,
      defaultValue: false,
      nearYouLabel: {"de": "Flughäfen in der Nähe"},
    ),
    "ferry": TransportModeConfig(
      availableForSelection: false,
      defaultValue: false,
      nearYouLabel: {"de": "Fähranleger in der Nähe"},
    ),
    "carpool": TransportModeConfig(
      availableForSelection: true,
      defaultValue: true,
      nearYouLabel: {
        "de": "Mitfahrpunkte in der Nähe",
        "en": "Nearby carpool stops on the map",
      },
    ),
    "funicular": TransportModeConfig(
      availableForSelection: true,
      defaultValue: true,
    ),
    "citybike": TransportModeConfig(
      availableForSelection: true,
      defaultValue: false,
      nearYouLabel: {
        "de": "Sharing-Angebote in der Nähe",
        "en": "Shared mobility near you",
      },
    ),
  },
  modeToOTP: {'carpool': 'CARPOOL'},
);

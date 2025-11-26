import 'package:latlong2/latlong.dart';
import 'package:trufi_core/configuration/config_default/config_default.dart';
import 'package:trufi_core/configuration/config_default/config_default/city_bike_config.dart';
import 'package:trufi_core/configuration/config_default/config_default/transport_mode_config.dart';

abstract class ModeUtils {
  static bool isCitybikeSeasonActive(SeasonConfig? season) {
    if (season == null) {
      return true;
    }

    final DateTime currentDate = DateTime.now();

    return currentDate.isAfter(season.start) &&
        currentDate.isBefore(season.end);
  }

  static bool networkIsActive(ConfigData config, String networkName) {
    var networks = config.cityBike.networks ?? {};

    return citybikeRoutingIsActive(networks[networkName]);
  }

  /// Retrieves all transport modes and returns the currently available
  /// modes together with WALK mode. If user has no ability to change
  /// mode settings, always use default modes.
  ///
  /// @param {*} config The configuration for the software
  /// @returns {String[]} returns user set modes or default modes
  static List<String> getModes(
    ConfigData config,
    List<String> modes,
    List<String> allowedVehicleRentalNetworks,
  ) {
    // Filter active vehicle rental networks
    List<String> activeAndAllowedVehicleRentalNetworks =
        allowedVehicleRentalNetworks
            .where((x) => networkIsActive(config, x))
            .toList();

    // Case 1: Show mode settings and valid transport modes exist
    if (showModeSettings(config) && modes.isNotEmpty) {
      List<String> transportModes = modes
          .where((mode) => isTransportModeAvailable(config, mode))
          .toList();

      List<String> modesWithWalk = [...transportModes, "WALK"];

      if (activeAndAllowedVehicleRentalNetworks.isNotEmpty &&
          !modesWithWalk.contains("CITYBIKE")) {
        modesWithWalk.add("CITYBIKE");
      }
      return modesWithWalk;
    }

    // Case 2: Active rental networks exist, default modes + CITYBIKE
    if (activeAndAllowedVehicleRentalNetworks.isNotEmpty) {
      List<String> modesWithCitybike = getDefaultModes(config);
      modesWithCitybike.add("CITYBIKE");
      return modesWithCitybike;
    }

    // Case 3: No special conditions, return default modes
    return getDefaultModes(config);
  }

  static bool isTransportModeAvailable(ConfigData config, String mode) {
    return getAvailableTransportModes(config).contains(mode.toUpperCase());
  }

  static bool showModeSettings(ConfigData config) {
    return getAvailableTransportModes(config).length > 1;
  }

  static bool citybikeRoutingIsActive(NetworkConfig? network) {
    // TODO: `enabled` should be the default, even if not specified
    return (network?.enabled ?? false) &&
        isCitybikeSeasonActive(network?.season);
  }

  /// Maps the given modes (either a string array or a comma-separated string of values)
  /// to their OTP counterparts. Any modes with no counterpart available will be dropped
  /// from the output.
  ///
  /// @param {*} config The configuration for the software installation
  /// @param {String[]|String} modes The modes to filter
  /// @returns The filtered modes, or an empty string
  static List<String> filterModes(
    ConfigData config,
    List<String>? modes,
    LatLng? from,
    LatLng? to,
    List<LatLng>? intermediatePlaces,
  ) {
    if (modes == null) {
      return [];
    }

    // Split modes and filter based on availability
    List<String> filtered =
        modes.where((mode) => isModeAvailable(config, mode)).toList();

    // Map each mode using getOTPMode() and flatten the results
    List<String> mapped = filtered
        .map((mode) {
          return getOTPMode(config, mode);
        })
        .whereType<String>()
        .toList();

    // Return unique, sorted values
    mapped.sort();
    return mapped.toSet().toList();
  }

  /// Checks if mode does not exist in config's modePolygons or
  /// at least one of the given coordinates is inside any of the polygons defined for a mode
  ///
  /// @param {*} config The configuration for the software installation
  /// @param {String} mode The mode to check
  /// @param {*} places
  // TODO isModeAvailableInsidePolygons is not used for stadtnavi
  static bool isModeAvailableInsidePolygons(
    ConfigData config,
    String mode,
    List<LatLng> places,
  ) {
    // if (config.modePolygons.containsKey(mode) && places.isNotEmpty) {
    //   for (var place in places) {
    //     double lat = place.lat;
    //     double lon = place.lon;

    //     for (var boundingBox in config.modeBoundingBoxes[mode] ?? []) {
    //       if (isInBoundingBox(boundingBox, lat, lon) &&
    //           inside([lon, lat], config.modePolygons[mode]!)) {
    //         return true;
    //       }
    //     }
    //   }
    //   return false;
    // }
    return true;
  }

  /// Checks if the given transport mode has been configured as availableForSelection.
  ///
  /// @param {*} config The configuration for the software installation
  /// @param {String} mode The mode to check
  static bool isModeAvailable(ConfigData config, String mode) {
    List<String> availableModes = [
      "WALK",
      ...getAvailableTransportModes(config)
    ];
    return availableModes.contains(mode.toUpperCase());
  }

  /// Retrieves all transport modes that have specified "availableForSelection": true.
  /// Only the name of each transport mode will be returned.
  ///
  /// @param {*} config The configuration for the software installation
  static List<String> getAvailableTransportModes(ConfigData config) {
    return getAvailableTransportModeConfigs(config)
        .map((tm) => tm.name ?? '')
        .toList();
  }

  static bool useCitybikes(Map<String, NetworkConfig>? networks) {
    if (networks == null || networks.isEmpty) {
      return false;
    }

    return networks.values.any((network) => citybikeRoutingIsActive(network));
  }

  static List<String> getDefaultTransportModes(ConfigData config) {
    return getAvailableTransportModeConfigs(config)
        .where((tm) => tm.defaultValue)
        .map((tm) => tm.name ?? '')
        .toList();
  }

  static String? getOTPMode(ConfigData config, String? mode) {
    if (mode == null || mode.isEmpty) {
      return null;
    }

    String? otpMode = config.modeToOTP[mode.toLowerCase()];
    return otpMode?.toUpperCase();
  }

  static List<String> getDefaultModes(ConfigData config) {
    return [
      ...getDefaultTransportModes(config), // Get default transport modes
      "WALK", // Always include "WALK"
    ];
  }

  static List<TransportModeConfig> getAvailableTransportModeConfigs(
      ConfigData config) {
    Map<String, TransportModeConfig> transportModes = getTransportModes(config);

    return transportModes.entries
        .where((entry) => entry.value.availableForSelection)
        .map((entry) {
      entry.value.name = entry.key.toUpperCase();
      return entry.value;
    }).toList();
  }

  static Map<String, TransportModeConfig> getTransportModes(ConfigData config) {
    if (config.cityBike.networks != null &&
        config.cityBike.networks!.isNotEmpty &&
        !useCitybikes(config.cityBike.networks)) {
      return {
        ...config.transportModes,
        "citybike": TransportModeConfig(availableForSelection: false),
      };
    }
    return config.transportModes;
  }

  /// Filters away modes that do not allow bicycle boarding.
  ///
  /// @param {*} config The configuration for the software installation
  /// @param {String[]} modes modes to filter from
  /// @returns {String[]} result of filtering

  static List<String> getBicycleCompatibleModes(
      ConfigData config, List<String> modes) {
    return modes
        .where((mode) => !config.modesWithNoBike.contains(mode))
        .toList();
  }

  /// Transforms array of mode strings into modern format OTP mode objects
  ///
  /// @param {String[]} modes modes to filter from
  /// @returns {Object[]} array of objects of format
  /// {mode: <uppercase mode name>}, qualifier: <optional qualifier>}
  static List<Map<String, String>> modesAsOTPModes(List<String> modes) {
    return modes.map((mode) {
      List<String> modeAndQualifier = mode.split("_");
      return modeAndQualifier.length > 1
          ? {"mode": modeAndQualifier[0], "qualifier": modeAndQualifier[1]}
          : {"mode": modeAndQualifier[0]};
    }).toList();
  }
}

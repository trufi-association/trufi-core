// Re-export from trufi_core_interfaces for backward compatibility
export 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show
        TrufiPlace,
        TrufiLocation,
        TrufiStreet,
        TrufiStreetJunction,
        LevenshteinObject,
        LocationModel,
        Geometry;

// Re-export LocationDetail for backward compatibility
export 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show LocationDetail;

import 'package:trufi_core/base/models/enums/defaults_location.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart' as interfaces;

/// Extension to add localization support to TrufiLocation.
extension TrufiLocationDisplayName on interfaces.TrufiLocation {
  String displayName(SavedPlacesLocalization localization) {
    String translate = description;
    if (translate == '') {
      translate = localization.selectedOnMap;
    } else if (type == DefaultLocation.defaultHome.initLocation.type &&
        description == DefaultLocation.defaultHome.initLocation.description) {
      translate = isLatLngDefined
          ? localization.defaultLocationHome
          : localization.defaultLocationAdd(
              localization.defaultLocationHome.toLowerCase());
    } else if (type == DefaultLocation.defaultWork.initLocation.type &&
        description == DefaultLocation.defaultWork.initLocation.description) {
      translate = isLatLngDefined
          ? localization.defaultLocationWork
          : localization.defaultLocationAdd(
              localization.defaultLocationWork.toLowerCase());
    }
    return translate;
  }
}

/// Extension to add localization support to TrufiStreet.
extension TrufiStreetDisplayName on interfaces.TrufiStreet {
  String displayName(SavedPlacesLocalization localization) =>
      location.displayName(localization);
}

/// Extension to add localization support to TrufiStreetJunction.
extension TrufiStreetJunctionDisplayName on interfaces.TrufiStreetJunction {
  String displayName(SavedPlacesLocalization localization) =>
      localization.instructionJunction(
        street1.location.displayName(localization),
        street2.location.displayName(localization),
      );

  interfaces.TrufiLocation location(SavedPlacesLocalization localization) {
    return interfaces.TrufiLocation(
      description: displayName(localization),
      latitude: latitude,
      longitude: longitude,
    );
  }
}


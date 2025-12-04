import 'package:trufi_core_routing/trufi_core_routing.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

/// App-specific translation extension for [TransportMode].
///
/// This stays in the app because it depends on [TrufiBaseLocalization].
extension TransportModeTranslations on TransportMode {
  /// Localized name for this transport mode.
  String getTranslate(TrufiBaseLocalization localization) {
    return switch (this) {
      TransportMode.bicycle => localization.instructionVehicleBike,
      TransportMode.bus => localization.instructionVehicleBus,
      TransportMode.cableCar => localization.instructionVehicleGondola,
      TransportMode.car => localization.instructionVehicleCar,
      TransportMode.carPool => localization.instructionVehicleCarpool,
      TransportMode.ferry => localization.instructionVehicleMetro,
      TransportMode.gondola => localization.instructionVehicleGondola,
      TransportMode.rail => localization.instructionVehicleLightRail,
      TransportMode.subway => localization.instructionVehicleMetro,
      TransportMode.tram => localization.instructionVehicleCommuterTrain,
      TransportMode.trufi => localization.instructionVehicleTrufi,
      TransportMode.micro => localization.instructionVehicleMicro,
      TransportMode.miniBus => localization.instructionVehicleMinibus,
      TransportMode.lightRail => localization.instructionVehicleLightRail,
      _ => 'Unknown',
    };
  }
}

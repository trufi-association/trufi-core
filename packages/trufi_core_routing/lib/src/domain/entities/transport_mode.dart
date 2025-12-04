/// Transport modes supported by OpenTripPlanner.
enum TransportMode {
  /// Represents an error or unrecognized transport mode.
  error,
  airplane,
  bicycle,
  bus,
  cableCar,
  car,
  carPool,
  ferry,
  flexible,
  funicular,
  gondola,
  legSwitch,
  rail,
  subway,
  tram,
  transit,
  walk,
  // Specific transport types
  trufi,
  micro,
  miniBus,
  lightRail,
  /// @deprecated Use [error] instead.
  @Deprecated('Use TransportMode.error instead')
  unknown,
}

/// Extension methods for [TransportMode].
extension TransportModeExtension on TransportMode {
  /// OTP string representation.
  static const _names = <TransportMode, String>{
    TransportMode.error: 'ERROR',
    TransportMode.airplane: 'AIRPLANE',
    TransportMode.bicycle: 'BICYCLE',
    TransportMode.bus: 'BUS',
    TransportMode.cableCar: 'CABLE_CAR',
    TransportMode.car: 'CAR',
    TransportMode.carPool: 'CARPOOL',
    TransportMode.ferry: 'FERRY',
    TransportMode.flexible: 'FLEXIBLE',
    TransportMode.funicular: 'FUNICULAR',
    TransportMode.gondola: 'GONDOLA',
    TransportMode.legSwitch: 'LEG_SWITCH',
    TransportMode.rail: 'RAIL',
    TransportMode.subway: 'SUBWAY',
    TransportMode.tram: 'TRAM',
    TransportMode.transit: 'TRANSIT',
    TransportMode.walk: 'WALK',
    TransportMode.trufi: 'TRUFI',
    TransportMode.micro: 'MICRO',
    TransportMode.miniBus: 'MINIBUS',
    TransportMode.lightRail: 'LIGHT RAIL',
    TransportMode.unknown: 'UNKNOWN',
  };

  /// Returns the OTP string name for this transport mode.
  String get otpName => _names[this] ?? 'UNKNOWN';

  /// Creates a [TransportMode] from an OTP mode string.
  static TransportMode fromString(String? mode, {String? specificTransport}) {
    if (mode == null) return TransportMode.error;

    if (specificTransport != null) {
      final enumType = specificTransport.toUpperCase();
      if (enumType.contains('TRUFI')) return TransportMode.trufi;
      if (enumType.contains('MICRO')) return TransportMode.bus;
      if (enumType.contains('MINIBUS')) return TransportMode.miniBus;
      if (enumType.contains('GONDOLA')) return TransportMode.gondola;
      if (enumType.contains('LIGHT RAIL')) return TransportMode.lightRail;
    }

    return _names.entries
        .firstWhere(
          (entry) => entry.value == mode.toUpperCase(),
          orElse: () => const MapEntry(TransportMode.error, 'ERROR'),
        )
        .key;
  }
}

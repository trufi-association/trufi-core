import 'package:flutter/material.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import 'icons/transport_icons.dart';

/// Default transport modes for route planning.
const defaultTransportModes = <TransportMode>[
  TransportMode.bus,
  TransportMode.rail,
  TransportMode.subway,
  TransportMode.walk,
];

/// UI extensions for [TransportMode] from trufi_core_routing package.
///
/// Provides colors, icons, and images for transport modes.
/// For translations, use [TransportModeTranslations] mixin in your app.
extension TransportModeUI on TransportMode {
  /// Default icon for this transport mode.
  IconData? get icon => _icons[this];

  static const _icons = <TransportMode, IconData?>{
    TransportMode.airplane: Icons.airplanemode_active,
    TransportMode.bicycle: Icons.directions_bike,
    TransportMode.bus: Icons.directions_bus,
    TransportMode.cableCar: null,
    TransportMode.car: Icons.drive_eta,
    TransportMode.carPool: Icons.drive_eta,
    TransportMode.ferry: Icons.directions_ferry,
    TransportMode.flexible: Icons.warning,
    TransportMode.funicular: null,
    TransportMode.gondola: null,
    TransportMode.legSwitch: Icons.warning,
    TransportMode.rail: Icons.train,
    TransportMode.subway: Icons.directions_subway,
    TransportMode.tram: Icons.train,
    TransportMode.transit: Icons.directions_transit,
    TransportMode.walk: Icons.directions_walk,
    TransportMode.trufi: Icons.local_taxi,
    TransportMode.micro: Icons.directions_bus,
    TransportMode.miniBus: Icons.airport_shuttle,
    TransportMode.lightRail: Icons.train,
  };

  /// Custom SVG image widget for this transport mode.
  Widget? getCustomImage({Color? color}) {
    return switch (this) {
      TransportMode.bicycle =>
        bikeIcon(color: color ?? const Color(0xff666666)),
      TransportMode.bus => busIcon(color: color ?? const Color(0xffff260c)),
      TransportMode.cableCar =>
        gondolaIcon(color: color ?? const Color(0xff000000)),
      TransportMode.car => carIcon(color: color ?? const Color(0xff000000)),
      TransportMode.carPool =>
        carpoolIcon(color: color ?? const Color(0xff9fc727)),
      TransportMode.funicular =>
        gondolaIcon(color: color ?? const Color(0xff000000)),
      TransportMode.gondola =>
        gondolaIcon(color: color ?? const Color(0xff000000)),
      TransportMode.rail => railIcon(color: color ?? const Color(0xff018000)),
      TransportMode.subway =>
        subwayIcon(color: color ?? Colors.blueAccent[700]),
      TransportMode.walk => walkIcon(color: color ?? const Color(0xff000000)),
      _ => null,
    };
  }

  /// Foreground color for this transport mode.
  Color get color => _colors[this] ?? Colors.white;

  static final _colors = <TransportMode, Color?>{
    TransportMode.bicycle: const Color(0xff666666),
    TransportMode.gondola: Colors.black,
    TransportMode.walk: Colors.grey[700],
  };

  /// Background color for this transport mode.
  Color get backgroundColor =>
      _backgroundColors[this] ?? const Color(0xff1B3661);

  static final _backgroundColors = <TransportMode, Color?>{
    TransportMode.bicycle: Colors.grey[200],
    TransportMode.bus: const Color(0xffff260c),
    TransportMode.car: Colors.black,
    TransportMode.carPool: const Color(0xff9fc726),
    TransportMode.ferry: const Color(0xff1B3661),
    TransportMode.rail: const Color(0xff018000),
    TransportMode.subway: Colors.blueAccent[700],
    TransportMode.tram: const Color(0xff018000),
    TransportMode.walk: Colors.grey[200],
    TransportMode.trufi: const Color(0xffd81b60),
    TransportMode.micro: const Color(0xffd81b60),
    TransportMode.miniBus: const Color(0xffd81b60),
    TransportMode.lightRail: const Color(0xffd81b60),
  };

  /// OTP qualifier (e.g., 'RENT' for bicycle).
  String? get qualifier => _qualifiers[this];

  static const _qualifiers = <TransportMode, String>{
    TransportMode.bicycle: 'RENT',
  };

  /// Complete image widget with fallback to icon.
  Widget getImage({Color? color, double size = 24}) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      child: FittedBox(
        child: getCustomImage(color: color) ??
            (icon != null
                ? Icon(icon, color: color)
                : const Icon(Icons.error, color: Colors.red)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:trufi_core/models/enums/absolute_direction.dart';

enum AbsoluteDirection {
  north,
  northeast,
  east,
  southeast,
  south,
  southwest,
  west,
  northwest,
}

AbsoluteDirection getAbsoluteDirectionByString(String direction) {
  return CompassDirectionExtension.names.keys.firstWhere(
    (key) => key.name == direction,
    orElse: () => AbsoluteDirection.north,
  );
}

extension CompassDirectionExtension on AbsoluteDirection {
  static const names = <AbsoluteDirection, String>{
    AbsoluteDirection.north: 'NORTH',
    AbsoluteDirection.northeast: 'NORTHEAST',
    AbsoluteDirection.east: 'EAST',
    AbsoluteDirection.southeast: 'SOUTHEAST',
    AbsoluteDirection.south: 'SOUTH',
    AbsoluteDirection.southwest: 'SOUTHWEST',
    AbsoluteDirection.west: 'WEST',
    AbsoluteDirection.northwest: 'NORTHWEST',
  };

  static const icons = <AbsoluteDirection, IconData>{
    AbsoluteDirection.north: Icons.north,
    AbsoluteDirection.northeast: Icons.north_east,
    AbsoluteDirection.east: Icons.east,
    AbsoluteDirection.southeast: Icons.south_east,
    AbsoluteDirection.south: Icons.south,
    AbsoluteDirection.southwest: Icons.south_west,
    AbsoluteDirection.west: Icons.west,
    AbsoluteDirection.northwest: Icons.north_west,
  };

  String get name => names[this] ?? 'NORTH';
  IconData get icon => icons[this] ?? Icons.help;

  AbsoluteDirectionTrufi toRealtimeState() {
    switch (this) {
      case AbsoluteDirection.north:
        return AbsoluteDirectionTrufi.north;
      case AbsoluteDirection.northeast:
        return AbsoluteDirectionTrufi.northeast;
      case AbsoluteDirection.east:
        return AbsoluteDirectionTrufi.east;
      case AbsoluteDirection.southeast:
        return AbsoluteDirectionTrufi.southeast;
      case AbsoluteDirection.south:
        return AbsoluteDirectionTrufi.south;
      case AbsoluteDirection.southwest:
        return AbsoluteDirectionTrufi.southwest;
      case AbsoluteDirection.west:
        return AbsoluteDirectionTrufi.west;
      case AbsoluteDirection.northwest:
        return AbsoluteDirectionTrufi.northwest;
    }
  }
}

import 'package:flutter/material.dart';

enum AbsoluteDirectionTrufi {
  north,
  northeast,
  east,
  southeast,
  south,
  southwest,
  west,
  northwest,
}

AbsoluteDirectionTrufi getAbsoluteDirectionByString(String direction) {
  return CompassDirectionExtension.names.keys.firstWhere(
    (key) => key.name == direction,
    orElse: () => AbsoluteDirectionTrufi.north,
  );
}

extension CompassDirectionExtension on AbsoluteDirectionTrufi {
  static const names = <AbsoluteDirectionTrufi, String>{
    AbsoluteDirectionTrufi.north: 'NORTH',
    AbsoluteDirectionTrufi.northeast: 'NORTHEAST',
    AbsoluteDirectionTrufi.east: 'EAST',
    AbsoluteDirectionTrufi.southeast: 'SOUTHEAST',
    AbsoluteDirectionTrufi.south: 'SOUTH',
    AbsoluteDirectionTrufi.southwest: 'SOUTHWEST',
    AbsoluteDirectionTrufi.west: 'WEST',
    AbsoluteDirectionTrufi.northwest: 'NORTHWEST',
  };

  static const icons = <AbsoluteDirectionTrufi, IconData>{
    AbsoluteDirectionTrufi.north: Icons.north,
    AbsoluteDirectionTrufi.northeast: Icons.north_east,
    AbsoluteDirectionTrufi.east: Icons.east,
    AbsoluteDirectionTrufi.southeast: Icons.south_east,
    AbsoluteDirectionTrufi.south: Icons.south,
    AbsoluteDirectionTrufi.southwest: Icons.south_west,
    AbsoluteDirectionTrufi.west: Icons.west,
    AbsoluteDirectionTrufi.northwest: Icons.north_west,
  };

  String get name => names[this] ?? 'NORTH';
  IconData get icon => icons[this] ?? Icons.help;
}

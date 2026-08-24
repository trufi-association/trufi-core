import 'package:flutter/material.dart';

/// Single source of truth for the icons a custom saved place can carry.
///
/// The edit dialog offers every entry of [savedPlaceIcons] and the list tile
/// resolves the persisted `iconName` through [savedPlaceRoundedIcon]. Keeping
/// both surfaces on this one table is what guarantees that every icon a user
/// can pick also renders back after saving (#985 — the selector and the tile
/// used to keep separate lists, and the five keys missing from the tile fell
/// back to the generic pin).
class SavedPlaceIcon {
  const SavedPlaceIcon(this.name, this.outlined, this.rounded);

  /// Stable key persisted in `SavedPlace.iconName`. Never rename existing
  /// keys: they live in the user's storage.
  final String name;

  /// Variant shown in the edit dialog selector.
  final IconData outlined;

  /// Variant shown in lists and tiles.
  final IconData rounded;
}

/// Every icon offered by the edit dialog, in display order.
const List<SavedPlaceIcon> savedPlaceIcons = [
  SavedPlaceIcon('place', Icons.place_outlined, Icons.place_rounded),
  SavedPlaceIcon('star', Icons.star_outline, Icons.star_rounded),
  SavedPlaceIcon('favorite', Icons.favorite_outline, Icons.favorite_rounded),
  SavedPlaceIcon('bookmark', Icons.bookmark_outline, Icons.bookmark_rounded),
  SavedPlaceIcon('school', Icons.school_outlined, Icons.school_rounded),
  SavedPlaceIcon(
    'shopping',
    Icons.shopping_bag_outlined,
    Icons.shopping_bag_rounded,
  ),
  SavedPlaceIcon(
    'restaurant',
    Icons.restaurant_outlined,
    Icons.restaurant_rounded,
  ),
  SavedPlaceIcon('cafe', Icons.coffee_outlined, Icons.coffee_rounded),
  SavedPlaceIcon(
    'gym',
    Icons.fitness_center_outlined,
    Icons.fitness_center_rounded,
  ),
  SavedPlaceIcon(
    'hospital',
    Icons.local_hospital_outlined,
    Icons.local_hospital_rounded,
  ),
  SavedPlaceIcon('park', Icons.park_outlined, Icons.park_rounded),
  SavedPlaceIcon('airport', Icons.flight_outlined, Icons.flight_rounded),
  SavedPlaceIcon('train', Icons.train_outlined, Icons.train_rounded),
  SavedPlaceIcon(
    'bus',
    Icons.directions_bus_outlined,
    Icons.directions_bus_rounded,
  ),
  SavedPlaceIcon(
    'parking',
    Icons.local_parking_outlined,
    Icons.local_parking_rounded,
  ),
  SavedPlaceIcon(
    'gas',
    Icons.local_gas_station_outlined,
    Icons.local_gas_station_rounded,
  ),
];

/// Resolves a persisted icon key to its list variant. Unknown or null keys
/// fall back to the generic place pin.
IconData savedPlaceRoundedIcon(String? name) {
  for (final icon in savedPlaceIcons) {
    if (icon.name == name) return icon.rounded;
  }
  return Icons.place_rounded;
}

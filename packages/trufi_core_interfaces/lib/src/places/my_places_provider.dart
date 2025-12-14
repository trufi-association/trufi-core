import '../models/trufi_location.dart';

/// Represents a saved/favorite place.
class MyPlace implements ITrufiLocation {
  /// Unique identifier for this place.
  final String id;

  /// Display name of the place.
  final String name;

  @override
  final String? address;

  @override
  final double latitude;

  @override
  final double longitude;

  /// Type of place (home, work, other, history).
  final MyPlaceType placeType;

  /// Optional icon name for display.
  final String? iconName;

  const MyPlace({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.placeType,
    this.iconName,
  });

  @override
  String get description => name;

  @override
  String? get type {
    switch (placeType) {
      case MyPlaceType.home:
        return 'home';
      case MyPlaceType.work:
        return 'work';
      case MyPlaceType.other:
        return 'other';
      case MyPlaceType.history:
        return 'history';
    }
  }
}

/// Types of saved places.
enum MyPlaceType {
  home,
  work,
  other,
  history,
}

/// Interface for providing saved/favorite places.
///
/// Implement this interface to provide places from different sources
/// (e.g., Hive storage, remote API, etc.).
abstract class MyPlacesProvider {
  /// Gets the home location, if set.
  Future<MyPlace?> getHome();

  /// Gets the work location, if set.
  Future<MyPlace?> getWork();

  /// Gets all other saved places (excluding home, work, and history).
  Future<List<MyPlace>> getOtherPlaces();

  /// Gets all places to show in search (home, work, and other places).
  Future<List<MyPlace>> getMyPlaces();
}

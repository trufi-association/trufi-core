import 'package:equatable/equatable.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// One end of a saved trip.
///
/// Own value object instead of [TrufiLocation] so the JSON stays under this
/// package's control: coordinates decode through `(json[k] as num).toDouble()`
/// because dart2js serialises `5.0` as `5`, and an `as double` cast would
/// throw on web whenever the stored value happens to be integral.
class SavedRoutePoint extends Equatable {
  const SavedRoutePoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String? address;

  /// `type` reported by [toTrufiLocation], so consumers can tell a saved
  /// route endpoint from a search result or a saved place.
  static const String locationType = 'saved_route';

  factory SavedRoutePoint.fromTrufiLocation(TrufiLocation location) {
    return SavedRoutePoint(
      name: location.description,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
    );
  }

  TrufiLocation toTrufiLocation() {
    return TrufiLocation(
      description: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      type: locationType,
    );
  }

  TrufiLatLng get latLng => TrufiLatLng(latitude, longitude);

  /// True when [other] lies within [radiusMeters] of this point
  /// (great-circle distance, see [TrufiLatLng.distanceTo]).
  bool isNear(SavedRoutePoint other, {required double radiusMeters}) =>
      latLng.distanceTo(other.latLng) <= radiusMeters;

  factory SavedRoutePoint.fromJson(Map<String, dynamic> json) {
    return SavedRoutePoint(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  @override
  List<Object?> get props => [name, latitude, longitude, address];
}

/// A transit leg of the itinerary the user saved: just enough for a badge.
class SavedRouteTransitLeg extends Equatable {
  const SavedRouteTransitLeg({
    required this.shortName,
    this.colorHex,
    this.textColorHex,
    this.mode,
  });

  final String shortName;

  /// GTFS route colour as six hex digits without `#`; null when unknown.
  final String? colorHex;

  /// GTFS `route_text_color`, same shape; null lets the card pick a
  /// readable colour from [colorHex].
  final String? textColorHex;

  /// OTP mode name of the leg (`BUS`, `TRUFI`, `RAIL`…), which picks the
  /// badge icon. Null for routes saved before the field existed: the card
  /// then shows a bus.
  final String? mode;

  factory SavedRouteTransitLeg.fromJson(Map<String, dynamic> json) {
    return SavedRouteTransitLeg(
      shortName: json['shortName'] as String,
      colorHex: json['colorHex'] as String?,
      textColorHex: json['textColorHex'] as String?,
      mode: json['mode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'shortName': shortName,
    'colorHex': colorHex,
    'textColorHex': textColorHex,
    'mode': mode,
  };

  @override
  List<Object?> get props => [shortName, colorHex, textColorHex, mode];
}

/// Snapshot of the itinerary at save time, shown on the card as line badges
/// and distance / duration chips. Informative only: launching a saved route
/// always plans the trip again.
class SavedRouteSnapshot extends Equatable {
  const SavedRouteSnapshot({
    required this.transitLegs,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<SavedRouteTransitLeg> transitLegs;
  final int distanceMeters;
  final int durationSeconds;

  factory SavedRouteSnapshot.fromJson(Map<String, dynamic> json) {
    return SavedRouteSnapshot(
      transitLegs: (json['transitLegs'] as List<dynamic>)
          .map((e) => SavedRouteTransitLeg.fromJson(e as Map<String, dynamic>))
          .toList(),
      distanceMeters: (json['distanceMeters'] as num).toInt(),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transitLegs': transitLegs.map((e) => e.toJson()).toList(),
      'distanceMeters': distanceMeters,
      'durationSeconds': durationSeconds,
    };
  }

  @override
  List<Object?> get props => [transitLegs, distanceMeters, durationSeconds];
}

/// A bookmarked origin–destination trip (#1005).
class SavedRoute extends Equatable {
  const SavedRoute({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.createdAt,
    this.lastUsedAt,
    this.snapshot,
  });

  final String id;
  final String name;
  final SavedRoutePoint origin;
  final SavedRoutePoint destination;
  final DateTime createdAt;

  /// Last time the user launched the route; stored for future sorting, the
  /// list itself keeps insertion order.
  final DateTime? lastUsedAt;

  /// Null when the route was saved without an itinerary (or after a swap:
  /// the saved legs ride one direction, showing them reversed would lie).
  final SavedRouteSnapshot? snapshot;

  /// New route with a generated id (both coordinate pairs plus the creation
  /// instant, mirroring `SavedPlace.fromTrufiLocation`).
  factory SavedRoute.create({
    required String name,
    required SavedRoutePoint origin,
    required SavedRoutePoint destination,
    SavedRouteSnapshot? snapshot,
  }) {
    final now = DateTime.now();
    return SavedRoute(
      id:
          '${origin.latitude}_${origin.longitude}_'
          '${destination.latitude}_${destination.longitude}_'
          '${now.millisecondsSinceEpoch}',
      name: name,
      origin: origin,
      destination: destination,
      createdAt: now,
      snapshot: snapshot,
    );
  }

  /// Inverted copy: same id, name and timestamps, origin and destination
  /// exchanged, snapshot dropped (see [snapshot]).
  SavedRoute swapped() {
    return copyWith(
      origin: destination,
      destination: origin,
      clearSnapshot: true,
    );
  }

  /// Both endpoints within [radiusMeters] of [other]'s, same direction.
  bool isSameTripAs(SavedRoute other, {required double radiusMeters}) =>
      origin.isNear(other.origin, radiusMeters: radiusMeters) &&
      destination.isNear(other.destination, radiusMeters: radiusMeters);

  SavedRoute copyWith({
    String? id,
    String? name,
    SavedRoutePoint? origin,
    SavedRoutePoint? destination,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    SavedRouteSnapshot? snapshot,
    bool clearSnapshot = false,
  }) {
    return SavedRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
    );
  }

  factory SavedRoute.fromJson(Map<String, dynamic> json) {
    final snapshot = json['snapshot'] as Map<String, dynamic>?;
    final lastUsedAt = json['lastUsedAt'] as String?;
    return SavedRoute(
      id: json['id'] as String,
      name: json['name'] as String,
      origin: SavedRoutePoint.fromJson(json['origin'] as Map<String, dynamic>),
      destination: SavedRoutePoint.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: lastUsedAt == null ? null : DateTime.parse(lastUsedAt),
      snapshot: snapshot == null ? null : SavedRouteSnapshot.fromJson(snapshot),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'snapshot': snapshot?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    origin,
    destination,
    createdAt,
    lastUsedAt,
    snapshot,
  ];
}

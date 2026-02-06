/// GTFS Trip entity.
/// Represents a trip from trips.txt
class GtfsTrip {
  final String id;
  final String routeId;
  final String serviceId;
  final String? headsign;
  final String? shortName;
  final GtfsDirectionId? directionId;
  final String? blockId;
  final String? shapeId;
  final GtfsWheelchairAccessible wheelchairAccessible;
  final GtfsBikesAllowed bikesAllowed;

  const GtfsTrip({
    required this.id,
    required this.routeId,
    required this.serviceId,
    this.headsign,
    this.shortName,
    this.directionId,
    this.blockId,
    this.shapeId,
    this.wheelchairAccessible = GtfsWheelchairAccessible.noInfo,
    this.bikesAllowed = GtfsBikesAllowed.noInfo,
  });

  factory GtfsTrip.fromCsv(Map<String, String> row) {
    return GtfsTrip(
      id: row['trip_id'] ?? '',
      routeId: row['route_id'] ?? '',
      serviceId: row['service_id'] ?? '',
      headsign: row['trip_headsign'],
      shortName: row['trip_short_name'],
      directionId: row['direction_id'] != null
          ? GtfsDirectionId.fromValue(int.tryParse(row['direction_id']!) ?? 0)
          : null,
      blockId: row['block_id'],
      shapeId: row['shape_id'],
      wheelchairAccessible: GtfsWheelchairAccessible.fromValue(
        int.tryParse(row['wheelchair_accessible'] ?? '') ?? 0,
      ),
      bikesAllowed: GtfsBikesAllowed.fromValue(
        int.tryParse(row['bikes_allowed'] ?? '') ?? 0,
      ),
    );
  }
}

/// Direction ID for trips.
enum GtfsDirectionId {
  outbound(0),
  inbound(1);

  final int value;
  const GtfsDirectionId(this.value);

  static GtfsDirectionId fromValue(int value) {
    return GtfsDirectionId.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GtfsDirectionId.outbound,
    );
  }
}

/// Wheelchair accessibility for trips.
enum GtfsWheelchairAccessible {
  noInfo(0),
  accessible(1),
  notAccessible(2);

  final int value;
  const GtfsWheelchairAccessible(this.value);

  static GtfsWheelchairAccessible fromValue(int value) {
    return GtfsWheelchairAccessible.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GtfsWheelchairAccessible.noInfo,
    );
  }
}

/// Bikes allowed for trips.
enum GtfsBikesAllowed {
  noInfo(0),
  allowed(1),
  notAllowed(2);

  final int value;
  const GtfsBikesAllowed(this.value);

  static GtfsBikesAllowed fromValue(int value) {
    return GtfsBikesAllowed.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GtfsBikesAllowed.noInfo,
    );
  }
}

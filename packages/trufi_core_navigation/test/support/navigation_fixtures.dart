import 'package:latlong2/latlong.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

/// A [LocationService] with the permission granted and no GPS behind it:
/// the test moves the rider with [moveTo]. Distances are the real ones.
class FakeLocationService extends LocationService {
  FakeLocationService({LatLng? initial})
    : _location = initial == null ? null : _result(initial);

  LocationResult? _location;

  static LocationResult _result(LatLng position, {double? accuracy}) =>
      LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: accuracy,
      );

  @override
  LocationResult? get currentLocation => _location;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<bool> startTracking({
    int distanceFilter = 10,
    Object? accuracy,
  }) async => true;

  @override
  Future<void> stopTracking() async {}

  /// A new fix at [position]; listeners hear about it synchronously.
  void moveTo(LatLng position, {double? accuracy}) {
    _location = _result(position, accuracy: accuracy);
    notifyListeners();
  }

  /// Meters from [from] along [path], point by point.
  double metersAlong(LatLng from, List<LatLng> path) {
    var meters = 0.0;
    var previous = from;
    for (final point in path) {
      meters += distanceBetween(
        previous.latitude,
        previous.longitude,
        point.latitude,
        point.longitude,
      );
      previous = point;
    }
    return meters;
  }
}

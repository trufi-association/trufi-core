import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// Whether [location] is a "Go to lat, lon" result that popped before its
/// reverse geocode answered (#1023): named by its pair, no address yet.
bool isBareCoordinateLocation(SearchLocation location) =>
    location.id.startsWith('coordinates:') &&
    (location.address == null || location.address!.trim().isEmpty);

/// Looks the address of a bare coordinate location up through the app's
/// geocoder, the way the search screen does for its subtitle: the reverse
/// result's address, or its name when it has no address. Null when the
/// geocoder has nothing, throws, or does not answer within [timeout], so
/// the caller keeps the bare pair.
Future<String?> resolveCoordinateAddress(
  SearchLocationsCubit cubit,
  double latitude,
  double longitude, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  try {
    final reverse = await cubit
        .reverseGeocode(latitude, longitude)
        .timeout(timeout, onTimeout: () => null);
    if (reverse == null) return null;
    final address = reverse.address?.trim();
    if (address != null && address.isNotEmpty) return address;
    final name = reverse.displayName.trim();
    return name.isEmpty ? null : name;
  } catch (_) {
    return null;
  }
}

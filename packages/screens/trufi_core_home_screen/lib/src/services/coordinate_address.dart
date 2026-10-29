import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// Whether [location] is a "Go to lat, lon" result that popped before its
/// reverse geocode answered (#1023): named by its pair, no address yet.
bool isBareCoordinateLocation(SearchLocation location) =>
    location.id.startsWith('coordinates:') &&
    (location.address == null || location.address!.trim().isEmpty);

/// Looks the address of a bare coordinate location up through the app's
/// geocoder and returns the same text the search screen stores when the row
/// is chosen after the answer: the reverse result's [SearchLocation.formattedDisplay]
/// (name and address, or whichever it has). Null when the geocoder has
/// nothing, throws, or does not answer within [timeout], so the caller keeps
/// the bare pair.
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
    final address = reverse.formattedDisplay.trim();
    return address.isEmpty ? null : address;
  } catch (_) {
    return null;
  }
}

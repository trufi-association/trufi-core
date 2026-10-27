import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// The subtitle a saved place gets from a reverse-geocode answer (#1003).
///
/// Photon answers a street point with `displayName` "Av. Heroínas" and
/// `address` "Av. Heroínas, Cochabamba, Bolivia", and a POI with the POI's
/// name plus an address that does not repeat it. Keep both when they add
/// information, never duplicate the name; null when the answer is empty.
String? addressFromReverseGeocode(SearchLocation location) {
  final name = location.displayName.trim();
  final address = location.address?.trim() ?? '';
  if (address.isEmpty) return name.isEmpty ? null : name;
  if (name.isEmpty || address.toLowerCase().contains(name.toLowerCase())) {
    return address;
  }
  return '$name, $address';
}

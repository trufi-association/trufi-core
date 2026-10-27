import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

import '../models/saved_place.dart';

/// The subtitle a saved place gets from a reverse-geocode answer (#1003).
///
/// Photon answers a street point with `displayName` "Av. Heroínas" and
/// `address` "Av. Heroínas, Cochabamba, Bolivia", and a POI with the POI's
/// name plus an address that does not repeat it. Keep both when they add
/// information, never duplicate the name; null when the answer is empty.
String? addressFromReverseGeocode(SearchLocation location) {
  var name = location.displayName.trim();
  // A feature with no name, street or city is named by its coordinates (four
  // decimals): not a name. The sheet then falls back to its own label.
  if (looksLikeCoordinates(name)) name = '';
  final address = location.address?.trim() ?? '';
  if (address.isEmpty) return name.isEmpty ? null : name;
  if (name.isEmpty || _mentions(address, name)) return address;
  return '$name, $address';
}

/// Whether [address] names [name] as whole words, any case: "Heroínas" is in
/// "Av. Heroínas, Cochabamba", "Cala" is not in "Av. Calacoto, La Paz".
bool _mentions(String address, String name) => RegExp(
  '(?<![\\p{L}\\p{N}])${RegExp.escape(name)}(?![\\p{L}\\p{N}])',
  caseSensitive: false,
  unicode: true,
).hasMatch(address);

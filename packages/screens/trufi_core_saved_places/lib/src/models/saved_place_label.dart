import '../../l10n/saved_places_localizations.dart';
import 'saved_place.dart';

/// The label a list shows for [place].
///
/// Home and Work are created with the localized default label as their name
/// ("Casa", "Home", …); that label keeps following the UI language. Once the
/// user renames the place, the stored name wins (#898 — the tile used to
/// hard-code the default label for every home/work, so renames never showed
/// up in the list while the edit sheet, reading the stored name, did).
///
/// Single source of that label for the tile and for the cubit's same-name
/// notice (#1019): what the notice compares must be what the list shows.
String savedPlaceDisplayName(
  SavedPlace place,
  SavedPlacesLocalizations localization,
) {
  final name = place.name.trim();
  switch (place.type) {
    case SavedPlaceType.home:
      return name.isEmpty || _isDefaultLabel(name, (l) => l.home)
          ? localization.home
          : name;
    case SavedPlaceType.work:
      return name.isEmpty || _isDefaultLabel(name, (l) => l.work)
          ? localization.work
          : name;
    case SavedPlaceType.other:
    case SavedPlaceType.history:
      return place.name;
  }
}

/// Whether [name] is the default label of a home/work place in any supported
/// language (the name is stored in whatever language the app ran in).
bool _isDefaultLabel(
  String name,
  String Function(SavedPlacesLocalizations l10n) label,
) {
  final lower = name.toLowerCase();
  return SavedPlacesLocalizations.supportedLocales
      .map(lookupSavedPlacesLocalizations)
      .any((l10n) => label(l10n).toLowerCase() == lower);
}

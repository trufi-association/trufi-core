import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../../l10n/navigation_localizations.dart';

/// Locale-aware distance string (#945): the unit comes from the ARBs and the
/// digits and separators from NumberFormat for [locale], not from string
/// literals. Whole meters below a kilometer, one decimal of kilometers from
/// there on.
String formatNavigationDistance(
  NavigationLocalizations l10n,
  double meters, {
  required String locale,
}) {
  if (meters < 1000) {
    return l10n.navDistanceMeters(
      safeNumberFormat('#,##0', locale).format(meters.round()),
    );
  }
  return l10n.navDistanceKilometers(
    safeNumberFormat('#,##0.0', locale).format(meters / 1000),
  );
}

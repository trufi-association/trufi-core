import 'package:tr_translations/tr_translations.dart';

abstract class ItineraryLegUtils {
  static String distanceWithTranslation(
    double meters,
    TrufiLocalizations localizations,
  ) {
    final tempMeters = meters;

    if (tempMeters < 100) {
      final roundMeters = (tempMeters / 10).round() * 10;
      final distance = formatNumber(
        roundMeters > 0 ? roundMeters : 1,
        '#.0',
        localName: localizations.localeName,
      );
      return localizations.instructionDistanceMeters(distance);
    }

    if (tempMeters < 975) {
      final distance = formatNumber(
        (tempMeters / 50).round() * 50,
        '#.0',
        localName: localizations.localeName,
      );
      return localizations.instructionDistanceMeters(distance);
    }

    if (tempMeters < 10000) {
      final distance = formatNumber(
        ((tempMeters / 100).round() * 100) / 1000,
        '#.0',
        localName: localizations.localeName,
      );
      return localizations.instructionDistanceKm(distance);
    }

    if (tempMeters < 100000) {
      final distance = formatNumber(
        (tempMeters / 1000).round(),
        '#.0',
        localName: localizations.localeName,
      );
      return localizations.instructionDistanceKm(distance);
    }

    final distance = formatNumber(
      (tempMeters / 1000).round() * 10,
      '#.0',
      localName: localizations.localeName,
    );

    return localizations.instructionDistanceKm(distance);
  }
}

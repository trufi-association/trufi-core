import 'package:intl/intl.dart';
import 'package:trufi_core/localization/app_localization.dart';

abstract class ItineraryLegUtils {
  static String distanceWithTranslation(
    double meters,
    AppLocalization localization,
  ) {
    final tempMeters = meters;
    if (tempMeters < 100) {
      double roundMeters = (tempMeters / 10).round() * 10;

      return localization.translateWithParams(
        '${LocalizationKey.instructionDistanceMeters.key}:${_formatOneDecimals(localeName: localization.locale.languageCode).format(roundMeters > 0 ? roundMeters : 1)}',
      );
    }
    if (tempMeters < 975) {
      return localization.translateWithParams(
        '${LocalizationKey.instructionDistanceMeters.key}:${_formatOneDecimals(localeName: localization.locale.languageCode).format((tempMeters / 50).round() * 50)}',
      );
    }
    if (tempMeters < 10000) {
      return localization.translateWithParams(
        '${LocalizationKey.instructionDistanceKm.key}:${_formatOneDecimals(localeName: localization.locale.languageCode).format(((tempMeters / 100).round() * 100) / 1000)}',
      );
    }
    if (tempMeters < 100000) {
      return localization.translateWithParams(
        '${LocalizationKey.instructionDistanceKm.key}:${_formatOneDecimals(localeName: localization.locale.languageCode).format((tempMeters / 1000).round())}',
      );
    }
    return localization.translateWithParams(
      '${LocalizationKey.instructionDistanceKm.key}:${_formatOneDecimals(localeName: localization.locale.languageCode).format((tempMeters / 1000).round() * 10)}',
    );
  }

  static NumberFormat _formatOneDecimals({String? localeName}) {
    return NumberFormat('#.0', localeName ?? 'en');
  }
}

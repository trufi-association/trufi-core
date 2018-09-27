import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:trufi_app/trufi_localizations.dart';

class TrufiMaterialLocalizations extends DefaultMaterialLocalizations {
  static TrufiMaterialLocalizations of(BuildContext context) {
    return MaterialLocalizations.of(context);
  }

  TrufiMaterialLocalizations(this.locale);

  Locale locale;

  void switchToLanguage(String languageCode) {
    locale = TrufiLocalizations.getLocale(languageCode);
  }

  @override
  String get searchFieldLabel {
    switch (locale.languageCode) {
      case 'qu':
        return "Mask'ay";
      case "es":
        return "Buscar";
      case "de":
        return "Suchen";
      default:
        return super.searchFieldLabel;
    }
  }
}

class TrufiMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  TrufiMaterialLocalizationsDelegate(this.languageCode);

  final String languageCode;

  TrufiMaterialLocalizations localizations;

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'de', 'qu'].contains(locale.languageCode);
  }

  @override
  Future<TrufiMaterialLocalizations> load(Locale locale) async {
    localizations = await _getLocalizations();
    return localizations != null
        ? localizations
        : SynchronousFuture<TrufiMaterialLocalizations>(
            TrufiMaterialLocalizations(locale),
          );
  }

  @override
  bool shouldReload(TrufiMaterialLocalizationsDelegate old) {
    return localizations == null ? false : old.localizations != localizations;
  }

  Future<TrufiMaterialLocalizations> _getLocalizations() async {
    return languageCode != null
        ? TrufiMaterialLocalizations(TrufiLocalizations.getLocale(languageCode))
        : null;
  }
}

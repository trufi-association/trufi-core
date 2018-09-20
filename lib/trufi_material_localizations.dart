import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  TrufiMaterialLocalizations localizations;

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'de', 'qu'].contains(locale.languageCode);
  }

  @override
  Future<TrufiMaterialLocalizations> load(Locale locale) async {
    localizations = await _getLocalizations();
    if (localizations != null) {
      return localizations;
    }
    return SynchronousFuture<TrufiMaterialLocalizations>(TrufiMaterialLocalizations(locale));
  }

  @override
  bool shouldReload(TrufiMaterialLocalizationsDelegate old) {
    return localizations == null ? false : old.localizations != localizations;
  }

  Future<TrufiMaterialLocalizations> _getLocalizations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.get(TrufiLocalizations.savedLanguageCode);
    return languageCode != null
        ? TrufiMaterialLocalizations(TrufiLocalizations.getLocale(languageCode))
        : null;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_app/trufi_localizations.dart';

class TrufiMaterialLocalizations extends DefaultMaterialLocalizations {
  Locale locale;

  TrufiMaterialLocalizations(this.locale) : super();

  static TrufiMaterialLocalizations of(BuildContext context) {
    return MaterialLocalizations.of(context);
  }

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

  TrufiMaterialLocalizationsDelegate();

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
    return GlobalMaterialLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(TrufiMaterialLocalizationsDelegate old) =>
      localizations == null ? false : old.localizations != localizations;

  Future<TrufiMaterialLocalizations> _getLocalizations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.get(TrufiLocalizations.savedLanguageCode);
    return languageCode != null
        ? TrufiMaterialLocalizations(
            (TrufiLocalizations.getLocale(languageCode)))
        : null;
  }
}

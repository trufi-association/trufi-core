import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class TrufiLocalizations {
  TrufiLocalizations(this.locale);

  final Locale locale;

  static TrufiLocalizations of(BuildContext context) {
    return Localizations.of<TrufiLocalizations>(context, TrufiLocalizations);
  }

  static const String kTitle = "title";
  static const String kCommonDestination = "common_destination";
  static const String kCommonOrigin = "common_origin";
  static const String kSearchItemChooseOnMap = "search_item_choose_on_map";
  static const String kSearchItemYourLocation = "search_item_your_location";
  static const String kSearchSectionPlaces = "search_title_places";
  static const String kSearchSectionRecent = "search_title_recent";
  static const String kSearchSectionResults = "search_title_result";

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      kTitle: 'TrufiApp',
      kCommonDestination: 'Destination',
      kCommonOrigin: 'Origin',
      kSearchItemChooseOnMap: 'Choose on map',
      kSearchItemYourLocation: 'Your location',
      kSearchSectionPlaces: 'Places',
      kSearchSectionRecent: 'Recent',
      kSearchSectionResults: 'Search Results',
    },
    'es': {
      kTitle: 'TrufiApp',
      kCommonDestination: 'Destino',
      kCommonOrigin: 'Origen',
      kSearchItemChooseOnMap: 'Seleccionar en el mapa',
      kSearchItemYourLocation: 'Tu ubicación',
      kSearchSectionPlaces: 'Lugares',
      kSearchSectionRecent: 'Recientes',
      kSearchSectionResults: 'Resultados de búsqueda',
    },
    'de': {
      kTitle: 'TrufiApp',
      kCommonDestination: 'Fahrtziel',
      kCommonOrigin: 'Startpunkt',
      kSearchItemChooseOnMap: 'Auf der Karte auswählen',
      kSearchItemYourLocation: 'Ihr Standort',
      kSearchSectionPlaces: 'Orte',
      kSearchSectionRecent: 'Zuletzt gesucht',
      kSearchSectionResults: 'Suchergebnisse',
    },
  };

  String get title {
    return _localizedValues[locale.languageCode][kTitle];
  }

  String get commonDestination {
    return _localizedValues[locale.languageCode][kCommonDestination];
  }

  String get commonOrigin {
    return _localizedValues[locale.languageCode][kCommonOrigin];
  }

  String get searchItemChooseOnMap {
    return _localizedValues[locale.languageCode][kSearchItemChooseOnMap];
  }

  String get searchItemYourLocation {
    return _localizedValues[locale.languageCode][kSearchItemYourLocation];
  }

  String get searchTitlePlaces {
    return _localizedValues[locale.languageCode][kSearchSectionPlaces];
  }

  String get searchTitleRecent {
    return _localizedValues[locale.languageCode][kSearchSectionRecent];
  }

  String get searchTitleResults {
    return _localizedValues[locale.languageCode][kSearchSectionResults];
  }
}

class TrufiLocalizationsDelegate
    extends LocalizationsDelegate<TrufiLocalizations> {
  const TrufiLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'de'].contains(locale.languageCode);

  @override
  Future<TrufiLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<TrufiLocalizations>(TrufiLocalizations(locale));
  }

  @override
  bool shouldReload(TrufiLocalizationsDelegate old) => false;
}

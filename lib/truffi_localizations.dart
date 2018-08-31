import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class TruffiLocalizations {
  TruffiLocalizations(this.locale);

  final Locale locale;

  static TruffiLocalizations of(BuildContext context) {
    return Localizations.of<TruffiLocalizations>(context, TruffiLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'destination': 'Destination',
      'origin': 'Origin',
      'title': 'TruffiApp',
      'location': 'Your location',
      'choose': 'Choose on map',
      'recent': 'Recent',
      'search': 'Search Results',
      'places': 'Places',
    },
    'es': {
      'destination': 'Destino',
      'origin': 'Origen',
      'title': 'TruffiApp',
      'location': 'Tu ubicación',
      'choose': 'Seleccionar en el mapa',
      'recent': 'Recientes',
      'search': 'Resultados de búsqueda',
      'places': 'Lugares',
    },
    'de': {
      'destination': 'Fahrtziel',
      'origin': 'Startpunkt',
      'title': 'TruffiApp',
      'location': 'Ihr Standort',
      'choose': 'Auf Karte auswählen',
      'recent': 'zuletzt verwendeten',
      'search': 'Suchergebnisse',
      'places': 'Orten',
    },
  };

  String get destination {
    return _localizedValues[locale.languageCode]['destination'];
  }

  String get origin {
    return _localizedValues[locale.languageCode]['origin'];
  }

  String get title {
    return _localizedValues[locale.languageCode]['title'];
  }

  String get location {
    return _localizedValues[locale.languageCode]['location'];
  }

  String get chooseMap {
    return _localizedValues[locale.languageCode]['choose'];
  }

  String get recent {
    return _localizedValues[locale.languageCode]['recent'];
  }

  String get searchResults {
    return _localizedValues[locale.languageCode]['search'];
  }

  String get places {
    return _localizedValues[locale.languageCode]['places'];
  }
}

class TruffiLocalizationsDelegate
    extends LocalizationsDelegate<TruffiLocalizations> {
  const TruffiLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'de'].contains(locale.languageCode);

  @override
  Future<TruffiLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<TruffiLocalizations>(TruffiLocalizations(locale));
  }

  @override
  bool shouldReload(TruffiLocalizationsDelegate old) => false;
}

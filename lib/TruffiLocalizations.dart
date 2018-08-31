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
    },
    'es': {
      'destination': 'Destino',
      'origin': 'Origen',
      'title': 'TruffiApp',
    },
    'de': {
      'destination': 'Fahrtziel',
      'origin': 'Startpunkt',
      'title': 'TruffiApp',
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
}

class TruffiLocalizationsDelegate extends LocalizationsDelegate<TruffiLocalizations> {
  const TruffiLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es', 'de'].contains(locale.languageCode);

  @override
  Future<TruffiLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<TruffiLocalizations>(TruffiLocalizations(locale));
  }

  @override
  bool shouldReload(TruffiLocalizationsDelegate old) => false;
}
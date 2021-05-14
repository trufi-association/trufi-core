import 'package:flutter/material.dart';
import 'package:trufi_core/blocs/configuration/configuration.dart';
import 'package:trufi_core/blocs/configuration/models/animation_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/attribution.dart';
import 'package:trufi_core/blocs/configuration/models/language_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/map_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/url_collection.dart';

Configuration setupExampleConfiguration() {
  // Abbreviations
  final abbreviations = {
    "Avenida": "Av.",
    "Calle": "C.",
    "Camino": "C.º",
  };

  // Attribution
  final attribution = Attribution(
    representatives: [
      "Christoph Hanser",
      "Samuel Rioja",
    ],
    team: [
      "Andreas Helms",
      "Annika Bock",
      "Christian Brückner",
      "Javier Rocha",
      "Luz Choque",
      "Malte Dölker",
      "Martin Kleppe",
      "Michael Brückner",
      "Natalya Blanco",
      "Neyda Mili",
      "Raimund Wege",
    ],
    translators: [
      "Gladys Aguilar",
      "Jeremy Maes",
      "Gaia Vitali Roscini",
    ],
    routes: [
      "Trufi team",
      "Guia Cochala team",
    ],
    openStreetMap: [
      "Marco Antonio",
      "Noémie",
      "Philipp",
      "Felix D",
      "Valor Naram",
    ],
  );

  // Urls
  final urls = UrlCollection();

  // Map
  final map = MapConfiguration();

  // Languages
  final languages = [
    LanguageConfiguration("de", "DE", "Deutsch"),
    LanguageConfiguration("en", "US", "English"),
    LanguageConfiguration("es", "ES", "Español", isDefault: true),
    LanguageConfiguration("fr", "FR", "Français"),
    LanguageConfiguration("it", "IT", "Italiano"),
    LanguageConfiguration("qu", "BO", "Quechua simi"),
  ];

  final customTranslations = TrufiCustomLocalizations()
    ..title = {
      const Locale("de"): "Trufi App (German)",
      const Locale("en", "US"): "Trufi App (English)"
    }
    ..tagline = {
      const Locale("de"): "Tagline (German)",
      const Locale("en", "US"): "Tagline (English)"
    };

  return Configuration(
    customTranslations: customTranslations,
    supportedLanguages: languages,
    abbreviations: abbreviations,
    teamInformationEmail: "info@trufi.app",
    attribution: attribution,
    animations: AnimationConfiguration(),
    map: map,
    urls: urls,
    debug: true,
  );
}

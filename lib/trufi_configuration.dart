import 'package:flare_flutter/flare_actor.dart';
import 'package:trufi_core/blocs/configuration/models/language_configuration.dart';
import 'package:trufi_core/l10n/trufi_custom_localization.dart';

enum ServerType { defaultServer, graphQLServer }

class TrufiConfiguration {
  static final TrufiConfiguration _singleton = TrufiConfiguration._internal();

  factory TrufiConfiguration() {
    return _singleton;
  }

  TrufiConfiguration._internal();

  final abbreviations = <String, String>{};
  final customTranslations = TrufiCustomLocalizations();
  final generalConfiguration = TrufiGeneralConfiguration();

  // TODO: Could be removed by a Collection of Locale
  final List<LanguageConfiguration> languages = [];

  int minimumReviewWorthyActionCount = 3;
}

class TrufiGeneralConfiguration {
  String appCity = "Cochabamba";
  ServerType serverType = ServerType.defaultServer;
  bool debug = false;
}

class TrufiCustomLocalizations extends TrufiCustomLocalization {}

class TrufiConfigurationAnimation {
  FlareActor loading;
  FlareActor success;
}

class TrufiConfigurationAttribution {
  final representatives = [];
  final team = [];
  final translations = [];
  final routes = [];
  final osm = [];
}

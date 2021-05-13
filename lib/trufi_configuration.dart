import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_custom_localization.dart';

import 'models/definition_feedback.dart';
import 'widgets/map/map_copyright.dart';

enum ServerType { defaultServer, graphQLServer }

class TrufiConfiguration {
  static final TrufiConfiguration _singleton = TrufiConfiguration._internal();

  factory TrufiConfiguration() {
    return _singleton;
  }

  TrufiConfiguration._internal();

  final abbreviations = <String, String>{};
  final url = TrufiConfigurationUrl();
  final attribution = TrufiConfigurationAttribution();
  final customTranslations = TrufiCustomLocalizations();
  final generalConfiguration = TrufiGeneralConfiguration();
  final configurationDrawer = TrufiConfigurationDrawer();

  // TODO: Could be removed by a Collection of Locale
  final List<TrufiConfigurationLanguage> languages = [];

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

class TrufiConfigurationEmail {
  String feedback = "";
  String info = "";
}

class TrufiConfigurationImage {
  String drawerBackground = "";
}

class TrufiConfigurationLanguage {
  TrufiConfigurationLanguage({
    @required this.languageCode,
    @required this.countryCode,
    @required this.displayName,
    this.isDefault = false,
  });

  final String languageCode;
  final String countryCode;
  final String displayName;
  final bool isDefault;
}

class TrufiConfigurationMap {
  // ignore: prefer_function_declarations_over_variables
  WidgetBuilder buildMapAttribution = (context) => MapTileAndOSMCopyright();
}

class TrufiConfigurationUrl {
  final openStreetMapCopyright = "https://www.openstreetmap.org/copyright";
  final mapTilerCopyright = "https://www.maptiler.com/copyright/";
  String otpEndpoint = "";
  String routeFeedback = "";
  String donate = "";
  String share = "";
}

class TrufiConfigurationDrawer {
  DefinitionFeedBack definitionFeedBack;
}

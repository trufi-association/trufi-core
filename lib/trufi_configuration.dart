import 'package:trufi_core/blocs/configuration/models/language_configuration.dart';

enum ServerType { defaultServer, graphQLServer }

class TrufiConfiguration {
  static final TrufiConfiguration _singleton = TrufiConfiguration._internal();

  factory TrufiConfiguration() {
    return _singleton;
  }

  TrufiConfiguration._internal();

  final abbreviations = <String, String>{};
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

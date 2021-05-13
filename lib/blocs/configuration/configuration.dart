import 'package:trufi_core/blocs/configuration/models/attribution.dart';
import 'package:trufi_core/blocs/configuration/models/map_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/url_collection.dart';

/// A collection of all important configurations
class Configuration {
  /// Email that is shown inside of the Team Screen
  final String teamInformationEmail;

  /// Contains all Urls that can be configured inside of Trufi
  final UrlCollection urls;

  /// Everyone who is involved creating the application
  final Attribution attribution;

  final MapConfiguration map;

  Configuration({
    this.map,
    this.urls,
    this.teamInformationEmail,
    this.attribution,
  });
}

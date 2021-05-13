import 'package:flare_flutter/flare_actor.dart';
import 'package:trufi_core/blocs/configuration/models/attribution.dart';
import 'package:trufi_core/blocs/configuration/models/language_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/map_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/url_collection.dart';
import 'package:trufi_core/l10n/trufi_custom_localization.dart';
import 'package:trufi_core/models/definition_feedback.dart';
import 'package:trufi_core/services/plan_request/online_graphql_repository/online_graphql_repository.dart';
import 'package:trufi_core/services/plan_request/online_repository.dart';
import 'package:trufi_core/trufi_configuration.dart';

/// A collection of all important configurations
class Configuration {
  /// Email that is shown inside of the Team Screen
  final String teamInformationEmail;

  /// The Asset Path to the drawerBackgroundImage
  final String drawerBackgroundAssetPath;

  /// Contains all Urls that can be configured inside of Trufi
  final UrlCollection urls;

  /// Everyone who is involved creating the application
  final Attribution attribution;

  /// All map related configurations for the Trufi Core
  final MapConfiguration map;

  /// TODO: Add Documentation
  final Map<String, String> abbreviations;

  /// Loading and Success Animation
  final AnimationConfiguration animations;

  /// This determines which Backend Server the app uses
  /// [OnlineGraphQLRepository] or [OnlineRepository]
  final ServerType serverType;

  /// All languages that the Host app should support
  final List<LanguageConfiguration> supportedLanguages;

  /// Custom Translations
  TrufiCustomLocalizations customTranslations = TrufiCustomLocalizations();

  /// Definition of the feedback if it is a URL or a Email
  final FeedbackDefinition feedbackDefinition;

  Configuration({
    this.customTranslations,
    this.feedbackDefinition,
    this.supportedLanguages = const [],
    this.serverType,
    this.drawerBackgroundAssetPath = "assets/images/drawer-bg.jpg",
    this.animations,
    this.abbreviations,
    this.map,
    this.urls,
    this.teamInformationEmail,
    this.attribution,
  });
}

class AnimationConfiguration {
  final FlareActor loading;
  final FlareActor success;

  AnimationConfiguration({this.loading, this.success});
}

class TrufiCustomLocalizations extends TrufiCustomLocalization {}

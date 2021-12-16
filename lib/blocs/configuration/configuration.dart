import 'package:flutter/material.dart';
import 'package:trufi_core/blocs/configuration/models/animation_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/attribution.dart';
import 'package:trufi_core/blocs/configuration/models/language_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/map_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/url_collection.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_custom_localization.dart';
import 'package:trufi_core/models/definition_feedback.dart';
import 'package:trufi_core/models/enums/server_type.dart';
import 'package:trufi_core/services/plan_request/online_graphql_repository/online_graphql_repository.dart';
import 'package:trufi_core/services/plan_request/online_repository.dart';

/// A collection of all important configurations
class Configuration {
  /// Email that is shown inside of the Team Screen
  final String teamInformationEmail;

  /// The Asset Path to the drawerBackgroundImage
  final String drawerBackgroundAssetPath;

  /// The Asset Path to the pageBackgroundImage
  final String pageBackgroundAssetPath;

  /// Contains all Urls that can be configured inside of Trufi
  final UrlCollection? urls;

  /// Everyone who is involved creating the application
  final Attribution? attribution;

  /// All map related configurations for the Trufi Core
  final MapConfiguration? map;

  /// Loading and Success Animation
  final AnimationConfiguration? animations;

  /// This determines which Backend Server the app uses
  /// [OnlineGraphQLRepository] or [OnlineRepository]
  final ServerType serverType;

  /// All languages that the Host app should support
  final List<LanguageConfiguration> supportedLanguages;

  /// Custom Translations
  final TrufiCustomLocalizations? customTranslations;

  /// Definition of the feedback if it is a URL or a Email
  final FeedbackDefinition? feedbackDefinition;

  /// The [aboutSection] is [Builder] that allows you to add information
  /// in the About page.
  final WidgetBuilder? aboutSection;

  /// City where the App is used
  final String appCity;

  /// Development support for verbose state changes
  final bool debug;

  final int minimumReviewWorthyActionCount;

  /// Show the weather in the drawer from FMI - Finnish Meteorological Institute
  final bool showWeather;

  /// PlanItineraryLeg injection extra option
  final Widget Function(BuildContext context, PlanItineraryLeg? planItineraryLeg)?
      planItineraryLegBuilder;

  Configuration({
    this.teamInformationEmail = "",
    this.minimumReviewWorthyActionCount = 3,
    this.debug = false,
    this.serverType = ServerType.defaultServer,
    this.appCity = "Cochabamba",
    this.supportedLanguages = const [],
    this.drawerBackgroundAssetPath = "assets/images/drawer-bg.jpg",
    this.pageBackgroundAssetPath = "assets/images/background-image.png",
    this.customTranslations,
    this.feedbackDefinition,
    this.aboutSection,
    this.animations,
    this.map,
    this.urls,
    this.attribution,
    this.showWeather = true,
    this.planItineraryLegBuilder,
  });
}

class TrufiCustomLocalizations extends TrufiCustomLocalization {}

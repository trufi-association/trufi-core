import 'dart:async';

import 'package:global_configuration/global_configuration.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import "package:trufi_app/translations/messages_all.dart";

final supportedLanguages = List<Map<String, dynamic>>
  .from(GlobalConfiguration().get("supportedLanguages"));
final defaultLang = supportedLanguages
  .firstWhere((lang) => lang["default"] ?? false);
final supportedLocales = supportedLanguages
  .map((lang) => Locale(lang["languageCode"], lang["countryCode"]))
  .toList();
final defaultLocale = Locale(defaultLang["languageCode"], defaultLang["countryCode"]);

class TrufiLocalizations {
  static TrufiLocalizations of(BuildContext context) {
    return Localizations.of<TrufiLocalizations>(context, TrufiLocalizations);
  }

  TrufiLocalizations(this.locale);

  final Locale locale;

  String title() =>
    Intl.message(
      "Trotro App",
      name: "title",
      desc: "The application's name",
    );

  String tagline() =>
    Intl.message(
      "Public transportation in Cochabamba",
      name: "tagline",
      desc: "A short marketing sentence that describes the app",
    );

  String description() =>
    Intl.message(
      "The best way to travel with trufis, micros and busses through Cochabamba.",
      name: "description",
      desc: "A sentence that describes the application's purpose",
    );

  String version(String version) =>
    Intl.message(
      "Version $version",
      name: "version",
      args: [version],
      desc: "The application's version",
      examples: const { "version": "1.0" },
    );

  String alertLocationServicesDeniedTitle() =>
    Intl.message(
      "No location",
      name: "alertLocationServicesDeniedTitle",
      desc: "Title of dialog that explains that access to location services was denied",
    );

  String alertLocationServicesDeniedMessage() =>
    Intl.message(
      "Please make sure your device has GPS and the Location settings are activated.",
      name: "alertLocationServicesDeniedMessage",
      desc: "Text of dialog that explains that access to location services was denied",
    );

  String commonOK() =>
    Intl.message(
      "OK",
      name: "commonOK",
      desc: "OK button label",
    );

  String commonCancel() =>
    Intl.message(
      "Cancel",
      name: "commonCancel",
      desc: "Cancel button label",
    );

  String commonGoOffline() =>
    Intl.message(
      "Go offline",
      name: "commonGoOffline",
      desc: "Go offline button label",
    );

  String commonGoOnline() =>
    Intl.message(
      "Go online",
      name: "commonGoOnline",
      desc: "Go online button label",
    );

  String commonDestination() =>
    Intl.message(
      "Destination",
      name: "commonDestination",
      desc: "Destination field label",
    );

  String commonOrigin() =>
    Intl.message(
      "Origin",
      name: "commonOrigin",
      desc: "Origin field label",
    );

  String commonNoInternet() =>
    Intl.message(
      "No internet connection.",
      name: "commonNoInternet",
      desc: "Message when internet connection is lost",
    );

  String commonFailLoading() =>
    Intl.message(
      "Failed to load data",
      name: "commonFailLoading",
      desc: "Message when data could not be loaded",
    );

  String commonUnknownError() =>
    Intl.message(
      "Unknown error",
      name: "commonUnknownError",
      desc: "Message when an unknown error has occured",
    );

  String commonError() =>
    Intl.message(
      "Error",
      name: "commonError",
      desc: "Message when an error has occured",
    );

  String noRouteError() =>
    Intl.message(
      "Sorry, we could not find a route. What do you want to do?",
      name: "noRouteError",
      desc: "Message when no route could be found after a route search"
    );

  String noRouteErrorActionCancel() =>
    Intl.message(
      "Try another destination",
      name: "noRouteErrorActionCancel",
      desc: "Button label to try another destination when no route could be found",
    );

  String noRouteErrorActionReportMissingRoute() =>
    Intl.message(
      "Report a missing route",
      name: "noRouteErrorActionReportMissingRoute",
      desc: "Button label to report a missing route when no route could be found",
    );

  String noRouteErrorActionShowCarRoute() =>
    Intl.message(
      "Show route by car",
      name: "noRouteErrorActionShowCarRoute",
      desc: "Button label to show the car route when no route could be found",
    );

  String errorServerUnavailable() =>
    Intl.message(
      "We're sorry. The trip planner is temporarily unavailable. Please try again later.",
      name: "errorServerUnavailable",
      desc: "Message that is displayed when the trip planning server was not available",
    );

  String errorOutOfBoundary() =>
    Intl.message(
      "Trip is not possible. You might be trying to plan a trip outside the map data boundary.",
      name: "errorOutOfBoundary",
      desc: "Message that is displayed when a trip could not be planned, because it would be outside of map data boundaries",
    );

  String errorPathNotFound() =>
    Intl.message(
      "Trip is not possible. Your start or end point might not be safely accessible (for instance, you might be starting on a residential street connected only to a highway).",
      name: "errorPathNotFound",
      desc: "Message that is displayed when a trip could not be planned, because the start or end point is not safely accessible",
    );

  String errorNoTransitTimes() =>
    Intl.message(
      "No transit times available. The date may be past or too far in the future or there may not be transit service for your trip at the time you chose.",
      name: "errorNoTransitTimes",
      desc: "Message that is displayed when a trip could not be planned, because there were no valid transit times available for the requested time",
    );

  String errorServerTimeout() =>
    Intl.message(
      "The trip planner is taking way too long to process your request. Please try again later.",
      name: "errorServerTimeout",
      desc: "Message that is displayed when a trip could not be planned, because the server is taking too long to respond",
    );

  String errorTrivialDistance() =>
    Intl.message(
      "Origin is within a trivial distance of the destination.",
      name: "errorTrivialDistance",
      desc: "Message that is displayed when a trip could not be planned, because origin and destination are too close to each other",
    );

  String errorServerCanNotHandleRequest() =>
    Intl.message(
      "The request has errors that the server is not willing or able to process.",
      name: "errorServerCanNotHandleRequest",
      desc: "Message that is displayed when a trip could not be planned, because the request had errors",
    );

  String errorUnknownOrigin() =>
    Intl.message(
      "Origin is unknown. Can you be a bit more descriptive?",
      name: "errorUnknownOrigin",
      desc: "Message that is displayed when a trip could not be planned, because the origin was not found",
    );

  String errorUnknownDestination() =>
    Intl.message(
      "Destination is unknown. Can you be a bit more descriptive?",
      name: "errorUnknownDestination",
      desc: "Message that is displayed when a trip could not be planned, because the destination was not found",
    );

  String errorUnknownOriginDestination() =>
    Intl.message(
      "Both origin and destination are unknown. Can you be a bit more descriptive?",
      name: "errorUnknownOriginDestination",
      desc: "Message that is displayed when a trip could not be planned, because both origin and destination were not found",
    );

  String errorNoBarrierFree() =>
    Intl.message(
      "Both origin and destination are not wheelchair accessible",
      name: "errorNoBarrierFree",
      desc: "Message that is displayed when a trip could not be planned, because both origin and destination are not wheelchair accessible",
    );

  String errorAmbiguousOrigin() =>
    Intl.message(
      "The trip planner is unsure of the location you want to start from. Please select from the following options, or be more specific.",
      name: "errorAmbiguousOrigin",
      desc: "Message that is displayed when a trip could not be planned, because the specified origin is ambiguous",
    );

  String errorAmbiguousDestination() =>
    Intl.message(
      "The trip planner is unsure of the location you want to go to. Please select from the following options, or be more specific.",
      name: "errorAmbiguousDestination",
      desc: "Message that is displayed when a trip could not be planned, because the specified destination is ambiguous",
    );

  String errorAmbiguousOriginDestination() =>
    Intl.message(
      "Both origin and destination are ambiguous. Please select from the following options, or be more specific.",
      name: "errorAmbiguousOriginDestination",
      desc: "Message that is displayed when a trip could not be planned, because the specified origin and destination are ambiguous",
    );

  String searchHintOrigin() =>
    Intl.message(
      "Choose starting point",
      name: "searchHintOrigin",
      desc: "Placeholder text for the origin field (in search state)",
    );

  String searchHintDestination() =>
    Intl.message(
      "Choose destination",
      name: "searchHintDestination",
      desc: "Placeholder text for the destination field (in search state)",
    );

  String searchItemChooseOnMap() =>
    Intl.message(
      "Choose on map",
      name: "searchItemChooseOnMap",
      desc: "Search option that allows to choose a point on the map",
    );

  String searchItemYourLocation() =>
    Intl.message(
      "Your location",
      name: "searchItemYourLocation",
      desc: "Search option that allows to use the current user location",
    );

  String searchItemNoResults() =>
    Intl.message(
      "No results",
      name: "searchItemNoResults",
      desc: "Message that is displayed when no results were found for the search term that was provided",
    );

  String searchTitlePlaces() =>
    Intl.message(
      "Places",
      name: "searchTitlePlaces",
      desc: "Search section title for common places",
    );

  String searchTitleRecent() =>
    Intl.message(
      "Recent",
      name: "searchTitleRecent",
      desc: "Search section title for recent location",
    );

  String searchTitleFavorites() =>
    Intl.message(
      "Favorites",
      name: "searchTitleFavorites",
      desc: "Search section title for locations marked as favorites",
    );

  String searchTitleResults() =>
    Intl.message(
      "Search Results",
      name: "searchTitleResults",
      desc: "Search section title for results found for the provided search term",
    );

  String searchPleaseSelectOrigin() =>
    Intl.message(
      "Select origin",
      name: "searchPleaseSelectOrigin",
      desc: "Placeholder text for the origin field (in map-visible state)",
    );

  String searchPleaseSelectDestination() =>
    Intl.message(
      "Select destination",
      name: "searchPleaseSelectDestination",
      desc: "Placeholder text for the destination field (in map-visible state)",
    );

  String searchFailLoadingPlan() =>
    Intl.message(
      "Failed to load plan.",
      name: "searchFailLoadingPlan",
      desc: "Message that is displayed when the response of the trip planning request could not be received",
    );

  String searchMapMarker() =>
    Intl.message(
      "Map Marker",
      name: "searchMapMarker",
      desc: "Location name displayed in search fields that represents a location choosen on the map",
    );

  String chooseLocationPageTitle() =>
    Intl.message(
      "Choose a point",
      name: "chooseLocationPageTitle",
      desc: "Page title when choosing a location on the map",
    );

  String chooseLocationPageSubtitle() =>
    Intl.message(
      "Pan & zoom map under pin",
      name: "chooseLocationPageSubtitle",
      desc: "Page subtitle when choosing a location on the map",
    );

  String instructionWalk(String duration, String distance, String location) =>
    Intl.message(
      "Walk $duration ($distance) to\n$location",
      name: "instructionWalk",
      args: [duration, distance, location],
      desc: "Itinerary instruction (walking)",
      examples: const { "duration": "10 min", "distance": "500 m", "location": "Avenida Heroínas" },
    );

  String instructionRide(String vehicle, String duration, String distance, String location) =>
    Intl.message(
      "Ride $vehicle for $duration ($distance) to\n$location",
      name: "instructionRide",
      args: [vehicle, duration, distance, location],
      desc: "Itinerary instruction (vehicle)",
      examples: const { "vehicle": "Bus 100", "duration": "10 min", "distance": "500 m", "location": "Avenida Heroínas" },
    );

  String instructionVehicleBus() =>
    Intl.message(
      "Bus",
      name: "instructionVehicleBus",
      desc: "Vehicle name (Bus)",
    );

  String instructionVehicleMicro() =>
    Intl.message(
      "Micro",
      name: "instructionVehicleMicro",
      desc: "Vehicle name (Micro)",
    );

  String instructionVehicleMinibus() =>
    Intl.message(
      "Minibus",
      name: "instructionVehicleMinibus",
      desc: "Vehicle name (Minibus)",
    );

  String instructionVehicleTrufi() =>
    Intl.message(
      "Trufi",
      name: "instructionVehicleTrufi",
      desc: "Vehicle name (Trufi)",
    );

  String instructionVehicleCar() =>
    Intl.message(
      "Car",
      name: "instructionVehicleCar",
      desc: "Vehicle name (Car)",
    );

  String instructionVehicleGondola() =>
    Intl.message(
      "Gondola",
      name: "instructionVehicleGondola",
      desc: "Vehicle name (Gondola)",
    );

  String instructionDurationMinutes(num value) =>
    Intl.message(
      "$value min",
      name: "instructionDurationMinutes",
      args: [value],
      desc: "Itinerary leg duration",
      examples: const { "value": 10 },
    );

  String instructionDistanceKm(num value) =>
    Intl.message(
      "$value km",
      name: "instructionDistanceKm",
      args: [value],
      desc: "Itinerary leg distance (km)",
      examples: const { "value": 10 },
    );

  String instructionDistanceMeters(num value) =>
    Intl.message(
      "$value m",
      name: "instructionDistanceMeters",
      args: [value],
      desc: "Itinerary leg distance (m)",
      examples: const { "value": 100 },
    );

  String menuConnections() =>
    Intl.message(
      "Show routes",
      name: "menuConnections",
      desc: "Menu item that shows the map/planned trip",
    );

  String menuAbout() =>
    Intl.message(
      "About",
      name: "menuAbout",
      desc: "Menu item that shows the about page",
    );

  String menuTeam() =>
    Intl.message(
      "Team",
      name: "menuTeam",
      desc: "Menu item that shows the team page",
    );

  String menuFeedback() =>
    Intl.message(
      "Send Feedback",
      name: "menuFeedback",
      desc: "Menu item that shows the feedback page",
    );

  String menuOnline() =>
    Intl.message(
      "Online",
      name: "menuOnline",
      desc: "Menu item that shows the state of online/offline routing",
    );

  String menuAppReview() =>
    Intl.message(
      "Rate the app",
      name: "menuAppReview",
      desc: "Menu item that triggers a native widget to rate the app",
    );

  String feedbackContent() =>
    Intl.message(
      "Do you have suggestions for our app or found some errors in the data? We would love to hear from you! Please make sure to add your email address or telephone, so we can respond to you.",
      name: "feedbackContent",
      desc: "Text displayed on the feedback page",
    );

  String feedbackTitle() =>
    Intl.message(
      "Send us an E-mail",
      name: "feedbackTitle",
      desc: "Title displayed on the feedback page",
    );
  
  String aboutContent() =>
    Intl.message(
      "We are a bolivian and international team of people that love and support public transport. We have developed this app to make it easy for people to use the transport system in Cochabamba and the surrounding area.",
      name: "aboutContent",
      desc: "Text displayed on the about page",
    );

  String aboutLicenses() => 
    Intl.message(
      "Licenses",
      name: "aboutLicenses",
      desc: "Button label to show licenses",
    );

  String teamContent() =>
    Intl.message(
      "We are an international team called Trufi Association that has created this app with the help of many volunteers! Do you want to improve the Trotro App and be part of our team? Please contact us via:",
      name: "teamContent",
      desc: "Text displayed on the team page, followed by a email link",
    );

  String teamSectionRepresentatives(String representatives) =>
    Intl.message(
      "Representatives: $representatives",
      name: "teamSectionRepresentatives",
      args: [representatives],
      desc: "List of representatives",
      examples: const { "representatives": "Mario, Luigi" },
    );

  String teamSectionTeam(String teamMembers) =>
    Intl.message(
      "Team: $teamMembers",
      name: "teamSectionTeam",
      args: [teamMembers],
      desc: "List of team members",
      examples: const { "teamMembers": "Peach, Toad, Daisy, Yoshi" },
    );

  String teamSectionTranslations(String translators) =>
    Intl.message(
      "Translations: $translators",
      name: "teamSectionTranslations",
      args: [translators],
      desc: "List of translators",
      examples: const { "translators": "Bowser, Koopa, Gumba, Lakitu" },
    );

  String teamSectionRoutes(String routeContributors, String osmContributors) =>
    Intl.message(
      "Routes: $routeContributors and all users that uploaded routes to OpenStreetMap, such as $osmContributors.\nContact us if you want to join the OpenStreetMap community!",
      name: "teamSectionRoutes",
      args: [routeContributors, osmContributors],
      desc: "List of route contributors",
      examples: const {
        "routeContributors": "Wario, Waluigi, Rosalina",
        "osmContributors": "Kamek, Birdo, Toadette, Bowser Jr.",
      },
    );
}

class TrufiMaterialLocalizations extends DefaultMaterialLocalizations {
  static TrufiMaterialLocalizations of(BuildContext context) {
    return MaterialLocalizations.of(context);
  }

  TrufiMaterialLocalizations(this.locale);

  final Locale locale;
  String _searchHinText;

  @override
  String get searchFieldLabel {
    return _searchHinText;
  }

  void setSearchHintText(String searchHintText) {
    _searchHinText = searchHintText;
  }
}

class TrufiLocalizationsDelegate
    extends TrufiLocalizationsDelegateBase<TrufiLocalizations> {
  TrufiLocalizationsDelegate(String languageCode) : super(languageCode);

  @override
  Future<TrufiLocalizations> load(Locale locale) async {
    if (languageCode != null) {
      locale = localeForLanguageCode(languageCode);
    }

    if (locale == null) {
      locale = defaultLocale;
    }

    final localeString = locale.toLanguageTag();
    await initializeMessages(localeString);
    Intl.defaultLocale = localeString;

    return TrufiLocalizations(locale);
  }
}

class TrufiMaterialLocalizationsDelegate
    extends TrufiLocalizationsDelegateBase<MaterialLocalizations> {
  TrufiMaterialLocalizationsDelegate(String languageCode) : super(languageCode);

  @override
  Future<TrufiMaterialLocalizations> load(Locale locale) async {
    if (languageCode != null) {
      locale = localeForLanguageCode(languageCode);
    }

    if (locale == null) {
      locale = defaultLocale;
    }

    return SynchronousFuture<TrufiMaterialLocalizations>(
      TrufiMaterialLocalizations(locale),
    );
  }
}

abstract class TrufiLocalizationsDelegateBase<T>
    extends LocalizationsDelegate<T> {
  TrufiLocalizationsDelegateBase(this.languageCode);

  final String languageCode;

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  @override
  bool shouldReload(TrufiLocalizationsDelegateBase<T> old) {
    return old.languageCode != languageCode;
  }

  Locale localeForLanguageCode(String languageCode) {
    for (var locale in supportedLocales) {
      if (locale.languageCode == languageCode) {
        return locale;
      }
    }

    return null;
  }
}

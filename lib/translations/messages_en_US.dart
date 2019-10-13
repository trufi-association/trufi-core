// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_US locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'en_US';

  static m0(value) => "${value} km";

  static m1(value) => "${value} m";

  static m2(value) => "${value} min";

  static m3(vehicle, duration, distance, location) => "Ride ${vehicle} for ${duration} (${distance}) to\n${location}";

  static m4(duration, distance, location) => "Walk ${duration} (${distance}) to\n${location}";

  static m5(url) => "Download Trufi App, the public transport app for Cochabamba, at ${url}";

  static m6(representatives) => "Representatives: ${representatives}";

  static m7(routeContributors, osmContributors) => "Routes: ${routeContributors} and all users that uploaded routes to OpenStreetMap, such as ${osmContributors}.\nContact us if you want to join the OpenStreetMap community!";

  static m8(teamMembers) => "Team: ${teamMembers}";

  static m9(translators) => "Translations: ${translators}";

  static m10(version) => "Version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "aboutContent" : MessageLookupByLibrary.simpleMessage("We are a bolivian and international team of people that love and support public transport. We have developed this app to make it easy for people to use the transport system in Cochabamba and the surrounding area."),
    "aboutLicenses" : MessageLookupByLibrary.simpleMessage("Licenses"),
    "aboutOpenSource" : MessageLookupByLibrary.simpleMessage("This app is released as open source on GitHub. Feel free to contribute or bring it to your own city."),
    "alertLocationServicesDeniedMessage" : MessageLookupByLibrary.simpleMessage("Please make sure your device has GPS and the Location settings are activated."),
    "alertLocationServicesDeniedTitle" : MessageLookupByLibrary.simpleMessage("No location"),
    "appReviewDialogButtonAccept" : MessageLookupByLibrary.simpleMessage("Write review"),
    "appReviewDialogButtonDecline" : MessageLookupByLibrary.simpleMessage("Not now"),
    "appReviewDialogContent" : MessageLookupByLibrary.simpleMessage("Support us with a review on the Google Play Store."),
    "appReviewDialogTitle" : MessageLookupByLibrary.simpleMessage("Enjoying Trufi?"),
    "chooseLocationPageSubtitle" : MessageLookupByLibrary.simpleMessage("Pan & zoom map under pin"),
    "chooseLocationPageTitle" : MessageLookupByLibrary.simpleMessage("Choose a point"),
    "commonCancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "commonDestination" : MessageLookupByLibrary.simpleMessage("Destination"),
    "commonError" : MessageLookupByLibrary.simpleMessage("Error"),
    "commonFailLoading" : MessageLookupByLibrary.simpleMessage("Failed to load data"),
    "commonGoOffline" : MessageLookupByLibrary.simpleMessage("Go offline"),
    "commonGoOnline" : MessageLookupByLibrary.simpleMessage("Go online"),
    "commonNoInternet" : MessageLookupByLibrary.simpleMessage("No internet connection."),
    "commonOK" : MessageLookupByLibrary.simpleMessage("OK"),
    "commonOrigin" : MessageLookupByLibrary.simpleMessage("Origin"),
    "commonUnknownError" : MessageLookupByLibrary.simpleMessage("Unknown error"),
    "description" : MessageLookupByLibrary.simpleMessage("The best way to travel with trufis, micros and busses through Cochabamba."),
    "donate" : MessageLookupByLibrary.simpleMessage("Donate"),
    "errorAmbiguousDestination" : MessageLookupByLibrary.simpleMessage("The trip planner is unsure of the location you want to go to. Please select from the following options, or be more specific."),
    "errorAmbiguousOrigin" : MessageLookupByLibrary.simpleMessage("The trip planner is unsure of the location you want to start from. Please select from the following options, or be more specific."),
    "errorAmbiguousOriginDestination" : MessageLookupByLibrary.simpleMessage("Both origin and destination are ambiguous. Please select from the following options, or be more specific."),
    "errorNoBarrierFree" : MessageLookupByLibrary.simpleMessage("Both origin and destination are not wheelchair accessible"),
    "errorNoTransitTimes" : MessageLookupByLibrary.simpleMessage("No transit times available. The date may be past or too far in the future or there may not be transit service for your trip at the time you chose."),
    "errorOutOfBoundary" : MessageLookupByLibrary.simpleMessage("Trip is not possible. You might be trying to plan a trip outside the map data boundary."),
    "errorPathNotFound" : MessageLookupByLibrary.simpleMessage("Trip is not possible. Your start or end point might not be safely accessible (for instance, you might be starting on a residential street connected only to a highway)."),
    "errorServerCanNotHandleRequest" : MessageLookupByLibrary.simpleMessage("The request has errors that the server is not willing or able to process."),
    "errorServerTimeout" : MessageLookupByLibrary.simpleMessage("The trip planner is taking way too long to process your request. Please try again later."),
    "errorServerUnavailable" : MessageLookupByLibrary.simpleMessage("We\'re sorry. The trip planner is temporarily unavailable. Please try again later."),
    "errorTrivialDistance" : MessageLookupByLibrary.simpleMessage("Origin is within a trivial distance of the destination."),
    "errorUnknownDestination" : MessageLookupByLibrary.simpleMessage("Destination is unknown. Can you be a bit more descriptive?"),
    "errorUnknownOrigin" : MessageLookupByLibrary.simpleMessage("Origin is unknown. Can you be a bit more descriptive?"),
    "errorUnknownOriginDestination" : MessageLookupByLibrary.simpleMessage("Both origin and destination are unknown. Can you be a bit more descriptive?"),
    "feedbackContent" : MessageLookupByLibrary.simpleMessage("Do you have suggestions for our app or found some errors in the data? We would love to hear from you! Please make sure to add your email address or telephone, so we can respond to you."),
    "feedbackTitle" : MessageLookupByLibrary.simpleMessage("Send us an E-mail"),
    "followOnFacebook" : MessageLookupByLibrary.simpleMessage("Follow us on Facebook"),
    "followOnInstagram" : MessageLookupByLibrary.simpleMessage("Follow us on Instagram"),
    "followOnTwitter" : MessageLookupByLibrary.simpleMessage("Follow us on Twitter"),
    "instructionDistanceKm" : m0,
    "instructionDistanceMeters" : m1,
    "instructionDurationMinutes" : m2,
    "instructionRide" : m3,
    "instructionVehicleBus" : MessageLookupByLibrary.simpleMessage("Bus"),
    "instructionVehicleCar" : MessageLookupByLibrary.simpleMessage("Car"),
    "instructionVehicleGondola" : MessageLookupByLibrary.simpleMessage("Gondola"),
    "instructionVehicleMicro" : MessageLookupByLibrary.simpleMessage("Micro"),
    "instructionVehicleMinibus" : MessageLookupByLibrary.simpleMessage("Minibus"),
    "instructionVehicleTrufi" : MessageLookupByLibrary.simpleMessage("Trufi"),
    "instructionWalk" : m4,
    "menuAbout" : MessageLookupByLibrary.simpleMessage("About"),
    "menuAppReview" : MessageLookupByLibrary.simpleMessage("Rate the app"),
    "menuConnections" : MessageLookupByLibrary.simpleMessage("Show routes"),
    "menuFeedback" : MessageLookupByLibrary.simpleMessage("Send Feedback"),
    "menuOnline" : MessageLookupByLibrary.simpleMessage("Online"),
    "menuShareApp" : MessageLookupByLibrary.simpleMessage("Share the app"),
    "menuTeam" : MessageLookupByLibrary.simpleMessage("Team"),
    "noRouteError" : MessageLookupByLibrary.simpleMessage("Sorry, we could not find a route. What do you want to do?"),
    "noRouteErrorActionCancel" : MessageLookupByLibrary.simpleMessage("Try another destination"),
    "noRouteErrorActionReportMissingRoute" : MessageLookupByLibrary.simpleMessage("Report a missing route"),
    "noRouteErrorActionShowCarRoute" : MessageLookupByLibrary.simpleMessage("Show route by car"),
    "readOurBlog" : MessageLookupByLibrary.simpleMessage("Read our blog"),
    "searchFailLoadingPlan" : MessageLookupByLibrary.simpleMessage("Failed to load plan."),
    "searchHintDestination" : MessageLookupByLibrary.simpleMessage("Choose destination"),
    "searchHintOrigin" : MessageLookupByLibrary.simpleMessage("Choose starting point"),
    "searchItemChooseOnMap" : MessageLookupByLibrary.simpleMessage("Choose on map"),
    "searchItemNoResults" : MessageLookupByLibrary.simpleMessage("No results"),
    "searchItemYourLocation" : MessageLookupByLibrary.simpleMessage("Your location"),
    "searchMapMarker" : MessageLookupByLibrary.simpleMessage("Map Marker"),
    "searchPleaseSelectDestination" : MessageLookupByLibrary.simpleMessage("Select destination"),
    "searchPleaseSelectOrigin" : MessageLookupByLibrary.simpleMessage("Select origin"),
    "searchTitleFavorites" : MessageLookupByLibrary.simpleMessage("Favorites"),
    "searchTitlePlaces" : MessageLookupByLibrary.simpleMessage("Places"),
    "searchTitleRecent" : MessageLookupByLibrary.simpleMessage("Recent"),
    "searchTitleResults" : MessageLookupByLibrary.simpleMessage("Search Results"),
    "shareAppText" : m5,
    "tagline" : MessageLookupByLibrary.simpleMessage("Public transportation in Cochabamba"),
    "teamContent" : MessageLookupByLibrary.simpleMessage("We are an international team called Trufi Association that has created this app with the help of many volunteers! Do you want to improve the Trufi App and be part of our team? Please contact us via:"),
    "teamSectionRepresentatives" : m6,
    "teamSectionRoutes" : m7,
    "teamSectionTeam" : m8,
    "teamSectionTranslations" : m9,
    "title" : MessageLookupByLibrary.simpleMessage("Trufi App"),
    "version" : m10
  };
}

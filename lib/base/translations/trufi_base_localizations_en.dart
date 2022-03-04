


import 'trufi_base_localizations.dart';

/// The translations for English (`en`).
class TrufiBaseLocalizationEn extends TrufiBaseLocalization {
  TrufiBaseLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String get alertLocationServicesDeniedMessage => 'Please make sure your device has GPS and the Location settings are activated.';

  @override
  String get alertLocationServicesDeniedTitle => 'No location';

  @override
  String get appReviewDialogButtonAccept => 'Write review';

  @override
  String get appReviewDialogButtonDecline => 'Not now';

  @override
  String get appReviewDialogContent => 'Support us with a review on the Google Play Store.';

  @override
  String get appReviewDialogTitle => 'Enjoying Trufi?';

  @override
  String get chooseLocationPageSubtitle => 'Pan & zoom map under pin';

  @override
  String get chooseLocationPageTitle => 'Choose a point';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirmLocation => 'Confirm location';

  @override
  String get commonDestination => 'Destination';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonError => 'Error';

  @override
  String get commonFromStation => 'from station';

  @override
  String get commonFromStop => 'from stop';

  @override
  String get commonItineraryNoTransitLegs => 'Leave when it suits you';

  @override
  String get commonLeavesAt => 'Leaves';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonNoInternet => 'No internet connection.';

  @override
  String get commonNoResults => 'No results';

  @override
  String get commonOK => 'OK';

  @override
  String get commonOrigin => 'Origin';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonSave => 'Save';

  @override
  String get commonTomorrow => 'Tomorrow';

  @override
  String get commonUnknownError => 'Unknown error';

  @override
  String get commonUnkownPlace => 'Unkown place';

  @override
  String get commonWait => 'Wait';

  @override
  String get commonWalk => 'Walk';

  @override
  String get commonYourLocation => 'Your location';

  @override
  String get errorAmbiguousDestination => 'The trip planner is unsure of the location you want to go to. Please select from the following options, or be more specific.';

  @override
  String get errorAmbiguousOrigin => 'The trip planner is unsure of the location you want to start from. Please select from the following options, or be more specific.';

  @override
  String get errorAmbiguousOriginDestination => 'Both origin and destination are ambiguous. Please select from the following options, or be more specific.';

  @override
  String get errorNoBarrierFree => 'Both origin and destination are not wheelchair accessible';

  @override
  String get errorNoConnectServer => 'No connect with server.';

  @override
  String get errorNoTransitTimes => 'No transit times available. The date may be past or too far in the future or there may not be transit service for your trip at the time you chose.';

  @override
  String get errorOutOfBoundary => 'Trip is not possible. You might be trying to plan a trip outside the map data boundary.';

  @override
  String get errorPathNotFound => 'Trip is not possible. Your start or end point might not be safely accessible (for instance, you might be starting on a residential street connected only to a highway).';

  @override
  String get errorServerCanNotHandleRequest => 'The request has errors that the server is not willing or able to process.';

  @override
  String get errorServerTimeout => 'The trip planner is taking way too long to process your request. Please try again later.';

  @override
  String get errorServerUnavailable => 'We\'re sorry. The trip planner is temporarily unavailable. Please try again later.';

  @override
  String get errorTrivialDistance => 'Origin is within a trivial distance of the destination.';

  @override
  String get errorUnknownDestination => 'Destination is unknown. Can you be a bit more descriptive?';

  @override
  String get errorUnknownOrigin => 'Origin is unknown. Can you be a bit more descriptive?';

  @override
  String get errorUnknownOriginDestination => 'Both origin and destination are unknown. Can you be a bit more descriptive?';

  @override
  String get followOnFacebook => 'Follow us on Facebook';

  @override
  String get followOnInstagram => 'Follow us on Instagram';

  @override
  String get followOnTwitter => 'Follow us on Twitter';

  @override
  String instructionDistanceKm(Object value) {
    return '$value km';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '$value m';
  }

  @override
  String instructionDurationHours(Object value) {
    return '$value h';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '$value min';
  }

  @override
  String get instructionVehicleBike => 'Bike';

  @override
  String get instructionVehicleBus => 'Bus';

  @override
  String get instructionVehicleCar => 'Car';

  @override
  String get instructionVehicleCarpool => 'Carpool';

  @override
  String get instructionVehicleCommuterTrain => 'Commuter train';

  @override
  String get instructionVehicleGondola => 'Gondola';

  @override
  String get instructionVehicleLightRail => 'Light Rail Train';

  @override
  String get instructionVehicleMetro => 'Metro';

  @override
  String get instructionVehicleMicro => 'Micro';

  @override
  String get instructionVehicleMinibus => 'Minibus';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String get instructionVehicleWalk => 'Walk';

  @override
  String get menuConnections => 'Route planner';

  @override
  String get menuSocialMedia => 'Social media';

  @override
  String get menuTransportList => 'Show routes';

  @override
  String get noRouteError => 'Sorry, we could not find a route. What do you want to do?';

  @override
  String get noRouteErrorActionCancel => 'Try another destination';

  @override
  String get noRouteErrorActionReportMissingRoute => 'Report a missing route';

  @override
  String get noRouteErrorActionShowCarRoute => 'Show route by car';

  @override
  String get readOurBlog => 'Read our blog';

  @override
  String get searchFailLoadingPlan => 'Failed to load plan.';

  @override
  String get searchHintDestination => 'Choose destination';

  @override
  String get searchHintOrigin => 'Choose starting point';

  @override
  String get searchPleaseSelectDestination => 'Select destination';

  @override
  String get searchPleaseSelectOrigin => 'Select origin';

  @override
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return 'Download $appTitle, the public transport app for $cityName, at $url';
  }

  @override
  String get themeModeDark => 'Dark Theme';

  @override
  String get themeModeLight => 'Light theme';

  @override
  String get themeModeSystem => 'System Default';
}

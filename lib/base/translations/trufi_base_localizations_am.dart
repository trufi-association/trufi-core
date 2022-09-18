import 'trufi_base_localizations.dart';

/// The translations for Amharic (`am`).
class TrufiBaseLocalizationAm extends TrufiBaseLocalization {
  TrufiBaseLocalizationAm([String locale = 'am']) : super(locale);

  @override
  String get alertLocationServicesDeniedMessage => 'ስልክዎ (መሳሪያዎ) የጂ.ፒ.ኤስ. ማገናኛ እንዳለው እና መገናኘቱንም ያረጋግጡ';

  @override
  String get alertLocationServicesDeniedTitle => 'ቦታው አልተገኘም';

  @override
  String get appReviewDialogButtonAccept => 'ምክር ፃፍ';

  @override
  String get appReviewDialogButtonDecline => 'አሁን አይሆንም';

  @override
  String get appReviewDialogContent => 'በ Google Play መደብር ላይ አንድ ምክር ጋር ይደግፉን.';

  @override
  String get appReviewDialogTitle => 'መተግበሪያ እየወደዱት ነው?';

  @override
  String get chooseLocationPageSubtitle => 'ካርታውን ከፒንኬሽን አንቀሳቅስ & ያጉሉ';

  @override
  String get chooseLocationPageTitle => 'አንድ ነጥብ ይምረጡ';

  @override
  String get commonCancel => 'ሰርዝ';

  @override
  String get commonConfirmLocation => 'Confirm location';

  @override
  String get commonDestination => 'መዳረሻ';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonError => 'ስህተት';

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
  String get commonNoInternet => 'ኢንተርኔት የለም';

  @override
  String get commonNoResults => 'No results';

  @override
  String get commonOK => 'እሺ';

  @override
  String get commonOrigin => 'መነሻ';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonSave => 'Save';

  @override
  String get commonTomorrow => 'Tomorrow';

  @override
  String get commonUnknownError => 'ያልታወቀ ስህተት';

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
  String get errorOutOfBoundary => 'ይህ ጉዞ የተሳሳተ ነው። ከተዘጋጄው የካርታ ክልል ውጭ ያለ ጉዞ ነው';

  @override
  String get errorPathNotFound => 'Trip is not possible. Your start or end point might not be safely accessible (for instance, you might be starting on a residential street connected only to a highway).';

  @override
  String get errorServerCanNotHandleRequest => 'The request has errors that the server is not willing or able to process.';

  @override
  String get errorServerTimeout => 'The trip planner is taking way too long to process your request. Please try again later.';

  @override
  String get errorServerUnavailable => 'ይቅርታ. የጉዞ ዕቅድ መተግበሪያው ለጊዜው አገልግሎት አይሰጥም. እባክዎ ጥቂት ቆይተው ይሞክሩ';

  @override
  String get errorTrivialDistance => 'Origin is within a trivial distance of the destination.';

  @override
  String get errorUnknownDestination => 'Destination is unknown. Can you be a bit more descriptive?';

  @override
  String get errorUnknownOrigin => 'Origin is unknown. Can you be a bit more descriptive?';

  @override
  String get errorUnknownOriginDestination => 'Both origin and destination are unknown. Can you be a bit more descriptive?';

  @override
  String get followOnFacebook => 'ፌስቡክ ላይ ይከተሉን';

  @override
  String get followOnInstagram => 'በ ኢንስተግራም ላይ ይከተሉን';

  @override
  String get followOnTwitter => 'በትዊተር ላይ ይከተሉን';

  @override
  String instructionDistanceKm(Object value) {
    return '$value ኪ.ሜ.';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '$value ሜ';
  }

  @override
  String instructionDurationHours(Object value) {
    return '$value h';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '$value ደቂቃ';
  }

  @override
  String get instructionVehicleBike => 'Bike';

  @override
  String get instructionVehicleBus => 'አውቶቡስ';

  @override
  String get instructionVehicleCar => 'መኪና';

  @override
  String get instructionVehicleCarpool => 'Carpool';

  @override
  String get instructionVehicleCommuterTrain => 'Commuter train';

  @override
  String get instructionVehicleGondola => 'Gondola';

  @override
  String get instructionVehicleLightRail => 'ቀላል ባቡር';

  @override
  String get instructionVehicleMetro => 'Metro';

  @override
  String get instructionVehicleMicro => 'Microbus';

  @override
  String get instructionVehicleMinibus => 'ሚኒባስ';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String get instructionVehicleWalk => 'ይሂዱ';

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
  String get searchFailLoadingPlan => 'ዕቅድ መጫን አልተሳካም።';

  @override
  String get searchHintDestination => 'መድረሻ ይምረጡ';

  @override
  String get searchHintOrigin => 'መነሻ ነጥብ ይምረጡ';

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

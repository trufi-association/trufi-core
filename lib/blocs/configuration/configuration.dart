/// A collection of all important configurations
class Configuration {
  /// Email that is shown inside of the Team Screen
  final String teamInformationEmail;

  /// Contains all Urls that can be configured inside of Trufi
  final UrlCollection urlConfiguration;

  /// Everyone who is involved creating the application
  final Attribution attribution;

  Configuration({
    this.urlConfiguration,
    this.teamInformationEmail,
    this.attribution,
  });
}

class UrlCollection {
  /// Email to send feedback of missing routes to the team
  final String routeFeedbackUrl;

  /// Api Endpoint for the OpenTripPlanner
  /// for more information about the OTP: https://www.opentripplanner.org/
  final String openTripPlannerUrl;

  /// Url for donations
  final String donationUrl;

  /// To share the application set this link to an appropriate page
  final String shareUrl;

  UrlCollection({
    this.routeFeedbackUrl,
    this.openTripPlannerUrl,
    this.donationUrl,
    this.shareUrl,
  });
}

class Attribution {
  /// Representatives of the Association or the application
  final List<String> representatives;

  /// All members of the team who worked on the application
  final List<String> team;

  /// All participating translators who worked on the application
  final List<String> translators;

  /// All route members who helped on the application
  final List<String> routes;

  /// All Open Street Map members who helped on the application
  final List<String> openStreetMap;

  Attribution({
    this.representatives,
    this.team,
    this.translators,
    this.routes,
    this.openStreetMap,
  });
}

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
    this.routeFeedbackUrl = "",
    this.openTripPlannerUrl = "",
    this.donationUrl = "",
    this.shareUrl = "",
  });
}

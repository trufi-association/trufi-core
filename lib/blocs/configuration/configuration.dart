/// A collection of all important configurations
class Configuration {
  /// Email that is shown inside of the Team Screen
  final String teamInformationEmail;

  /// Everyone who is involved creating the application
  final Attribution attribution;

  Configuration({this.teamInformationEmail, this.attribution});
}

class Attribution {
  final List<String> representatives;
  final List<String> team;
  final List<String> translators;
  final List<String> routes;
  final List<String> osm;

  Attribution({
    this.representatives,
    this.team,
    this.translators,
    this.routes,
    this.osm,
  });
}

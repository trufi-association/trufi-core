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

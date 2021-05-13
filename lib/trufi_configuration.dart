enum ServerType { defaultServer, graphQLServer }

class TrufiConfiguration {
  static final TrufiConfiguration _singleton = TrufiConfiguration._internal();

  factory TrufiConfiguration() {
    return _singleton;
  }

  TrufiConfiguration._internal();

  final abbreviations = <String, String>{};
}

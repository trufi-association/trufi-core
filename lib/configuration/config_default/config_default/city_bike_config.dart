class CityBikeConfig {
  static final defaultData = CityBikeConfig(
    showFullInfo: false,
    cityBikeMinZoom: 14,
    cityBikeSmallIconZoom: 14,
    fewAvailableCount: 3,
    buyInstructions: const {
      "fi": "Osta käyttöoikeutta päiväksi, viikoksi tai koko kaudeksi",
      "sv": "Köp ett abonnemang för en dag, en vecka eller för en hel säsong",
      "en": "Buy a daily, weekly or season pass",
    },
  );
  late bool showFullInfo;
  late int cityBikeMinZoom;
  late int cityBikeSmallIconZoom;
  late int fewAvailableCount;
  late Map<String, String> buyInstructions;
  int? minZoomStopsNearYou;
  bool? showStationId;
  bool? useSpacesAvailable;
  bool? showCityBikes;
  Map<String, NetworkConfig>? networks;
  Map<String, OperatorConfig>? operators;
  Map<String, FormFactor>? formFactors;

  CityBikeConfig({
    bool? showFullInfo,
    int? cityBikeMinZoom,
    int? cityBikeSmallIconZoom,
    int? fewAvailableCount,
    Map<String, String>? buyInstructions,
    this.minZoomStopsNearYou,
    this.showStationId,
    this.useSpacesAvailable,
    this.showCityBikes,
    this.networks,
    this.operators,
    this.formFactors,
  }) {
    this.showFullInfo = showFullInfo ?? defaultData.showFullInfo;
    this.cityBikeMinZoom = cityBikeMinZoom ?? defaultData.cityBikeMinZoom;
    this.cityBikeSmallIconZoom =
        cityBikeSmallIconZoom ?? defaultData.cityBikeSmallIconZoom;
    this.fewAvailableCount = fewAvailableCount ?? defaultData.fewAvailableCount;
    this.buyInstructions = buyInstructions ?? defaultData.buyInstructions;
  }

  factory CityBikeConfig.fromJson(Map<String, dynamic> json) {
    return CityBikeConfig(
      showFullInfo: json['showFullInfo'] ?? defaultData.showFullInfo,
      cityBikeMinZoom: json['cityBikeMinZoom'] ?? defaultData.cityBikeMinZoom,
      cityBikeSmallIconZoom:
          json['cityBikeSmallIconZoom'] ?? defaultData.cityBikeSmallIconZoom,
      fewAvailableCount:
          json['fewAvailableCount'] ?? defaultData.fewAvailableCount,
      buyInstructions: Map<String, String>.from(
          json['buyInstructions'] ?? defaultData.buyInstructions),
      minZoomStopsNearYou: json['minZoomStopsNearYou'],
      showStationId: json['showStationId'],
      useSpacesAvailable: json['useSpacesAvailable'],
      showCityBikes: json['showCityBikes'],
      networks: json['networks'] != null
          ? (json['networks'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, NetworkConfig.fromJson(value)),
            )
          : null,
      operators: json['operators'] != null
          ? (json['operators'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, OperatorConfig.fromJson(value)),
            )
          : null,
      formFactors: json['formFactors'] != null
          ? (json['formFactors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, FormFactor.fromJson(value)),
            )
          : null,
    );
  }
  CityBikeConfig copyWith({
    bool? showFullInfo,
    int? cityBikeMinZoom,
    int? cityBikeSmallIconZoom,
    int? fewAvailableCount,
    Map<String, String>? buyInstructions,
    int? minZoomStopsNearYou,
    bool? showStationId,
    bool? useSpacesAvailable,
    bool? showCityBikes,
    Map<String, NetworkConfig>? networks,
    Map<String, FormFactor>? formFactors,
  }) {
    return CityBikeConfig(
      showFullInfo: showFullInfo ?? this.showFullInfo,
      cityBikeMinZoom: cityBikeMinZoom ?? this.cityBikeMinZoom,
      cityBikeSmallIconZoom:
          cityBikeSmallIconZoom ?? this.cityBikeSmallIconZoom,
      fewAvailableCount: fewAvailableCount ?? this.fewAvailableCount,
      buyInstructions: buyInstructions ?? this.buyInstructions,
      minZoomStopsNearYou: minZoomStopsNearYou ?? this.minZoomStopsNearYou,
      showStationId: showStationId ?? this.showStationId,
      useSpacesAvailable: useSpacesAvailable ?? this.useSpacesAvailable,
      showCityBikes: showCityBikes ?? this.showCityBikes,
      networks: networks ?? this.networks,
      formFactors: formFactors ?? this.formFactors,
    );
  }
}

class NetworkConfig {
  String icon;
  String? operator;
  Map<String, String> name;
  String? type;
  List<String>? formFactors;
  bool hideCode;
  bool enabled;
  Map<String, String>? url;
  bool? visibleInSettingsUi;
  SeasonConfig? season;

  NetworkConfig({
    required this.icon,
    this.operator,
    required this.name,
    required this.type,
    this.formFactors,
    this.hideCode = true,
    required this.enabled,
    this.url,
    this.visibleInSettingsUi,
    this.season,
  });

  factory NetworkConfig.fromJson(Map<String, dynamic> json) {
    return NetworkConfig(
      icon: json['icon'] ?? '',
      operator: json['operator'],
      name: Map<String, String>.from(json['name'] ?? {}),
      type: json['type'],
      formFactors: json['formFactors'] != null
          ? List<String>.from(json['formFactors'])
          : null,
      hideCode: json['hideCode'] ?? true,
      enabled: json['enabled'] ?? false,
      url: json['url'] != null ? Map<String, String>.from(json['url']) : null,
      visibleInSettingsUi: json['visibleInSettingsUi'],
      season: json['season'] != null ? SeasonConfig.futureSeason() : null,
    );
  }
}

class SeasonConfig {
  final DateTime start;
  final DateTime end;
  final DateTime preSeasonStart;

  SeasonConfig({
    required this.start,
    required this.end,
    required this.preSeasonStart,
  });

  factory SeasonConfig.futureSeason() {
    int futureYear = DateTime.now().year + 10;
    return SeasonConfig(
      start: DateTime(futureYear, 1, 1),
      end: DateTime(futureYear, 12, 31),
      preSeasonStart: DateTime(DateTime.now().year, 1, 1),
    );
  }
  // factory SeasonConfig.fromJson(Map<String, dynamic> json) {
  //   return SeasonConfig(
  //     start: DateTime.parse(json['start']),
  //     end: DateTime.parse(json['end']),
  //     preSeasonStart: DateTime.parse(json['preSeasonStart']),
  //   );
  // }
}

class OperatorConfig {
  String? operatorId;
  String? icon;
  String? iconCode;
  Map<String, String>? name;
  Map<String, String>? url;
  Map<String, String>? colors;

  OperatorConfig({
    this.operatorId,
    this.icon,
    this.iconCode,
    this.name,
    this.url,
    this.colors,
  });

  factory OperatorConfig.fromJson(Map<String, dynamic> json) {
    return OperatorConfig(
      operatorId: json['operatorId'],
      icon: json['icon'],
      iconCode: json['iconCode'],
      name:
          json['name'] != null ? Map<String, String>.from(json['name']) : null,
      url: json['url'] != null ? Map<String, String>.from(json['url']) : null,
      colors: json['colors'] != null
          ? Map<String, String>.from(json['colors'])
          : null,
    );
  }
}

class FormFactor {
  Set<String>? operatorIds;
  Set<String>? networkIds;

  FormFactor({
    this.operatorIds,
    this.networkIds,
  });

  factory FormFactor.fromJson(Map<String, dynamic> json) {
    return FormFactor(
      operatorIds: json['operatorIds'] != null
          ? Set<String>.from(json['operatorIds'])
          : null,
      networkIds: json['networkIds'] != null
          ? Set<String>.from(json['networkIds'])
          : null,
    );
  }
}

class TransportModeConfig {
  bool availableForSelection;
  bool defaultValue;
  int? smallIconZoom;
  String? name;
  Map<String, String>? nearYouLabel;

  TransportModeConfig({
    this.availableForSelection = false,
    this.defaultValue = false,
    this.smallIconZoom,
    this.nearYouLabel,
    this.name,
  });

  factory TransportModeConfig.fromJson(Map<String, dynamic> json) {
    return TransportModeConfig(
      availableForSelection: json['availableForSelection'] ?? false,
      defaultValue: json['defaultValue'] ?? false,
      smallIconZoom: json['smallIconZoom'],
      name: json['name'],
      nearYouLabel: (json['nearYouLabel'] as Map?)?.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
    );
  }
}

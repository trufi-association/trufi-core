class DefaultOptions {
  static final defaultData = DefaultOptions(
    walkBoardCost: WalkBoardCost(),
    walkReluctance: WalkReluctance(),
    walkSpeed: const [0.69, 0.97, 1.2, 1.67, 2.22],
    bikeSpeed: const [2.77, 4.15, 5.55, 6.94, 8.33],
  );
  late WalkBoardCost walkBoardCost;
  late WalkReluctance walkReluctance;
  late List<double> walkSpeed;
  late List<double> bikeSpeed;

  DefaultOptions({
    WalkBoardCost? walkBoardCost,
    WalkReluctance? walkReluctance,
    List<double>? walkSpeed,
    List<double>? bikeSpeed,
  }) {
    this.walkBoardCost = walkBoardCost ?? defaultData.walkBoardCost;
    this.walkReluctance = walkReluctance ?? defaultData.walkReluctance;
    this.walkSpeed = walkSpeed ?? defaultData.walkSpeed;
    this.bikeSpeed = bikeSpeed ?? defaultData.bikeSpeed;
  }

  factory DefaultOptions.fromJson(Map<String, dynamic> json) {
    return DefaultOptions(
      walkBoardCost: json['walkBoardCost'] != null
          ? WalkBoardCost.fromJson(json['walkBoardCost'])
          : defaultData.walkBoardCost,
      walkReluctance: json['walkReluctance'] != null
          ? WalkReluctance.fromJson(json['walkReluctance'])
          : defaultData.walkReluctance,
      walkSpeed: json['walkSpeed'] != null
          ? List<double>.from(json['walkSpeed'])
          : defaultData.walkSpeed,
      bikeSpeed: json['bikeSpeed'] != null
          ? List<double>.from(json['bikeSpeed'])
          : defaultData.bikeSpeed,
    );
  }
}

class WalkBoardCost {
  static final defaultData = WalkBoardCost(
    least: 3600,
    less: 1200,
    more: 360,
    most: 120,
  );
  late int least;
  late int less;
  late int more;
  late int most;

  WalkBoardCost({
    int? least,
    int? less,
    int? more,
    int? most,
  }) {
    this.least = least ?? defaultData.least;
    this.less = less ?? defaultData.less;
    this.more = more ?? defaultData.more;
    this.most = most ?? defaultData.most;
  }

  factory WalkBoardCost.fromJson(Map<String, dynamic> json) {
    return WalkBoardCost(
      least: json['least'] ?? defaultData.least,
      less: json['less'] ?? defaultData.less,
      more: json['more'] ?? defaultData.more,
      most: json['most'] ?? defaultData.most,
    );
  }
}

class WalkReluctance {
  static final defaultData = WalkReluctance(
    least: 5.0,
    less: 3.0,
    more: 1.0,
    most: 0.2,
  );
  late double least;
  late double less;
  late double more;
  late double most;

  WalkReluctance({
    double? least,
    double? less,
    double? more,
    double? most,
  }) {
    this.least = least ?? defaultData.least;
    this.less = less ?? defaultData.less;
    this.more = more ?? defaultData.more;
    this.most = most ?? defaultData.most;
  }

  factory WalkReluctance.fromJson(Map<String, dynamic> json) {
    return WalkReluctance(
      least: json['least'] ?? defaultData.least,
      less: json['less'] ?? defaultData.less,
      more: json['more'] ?? defaultData.more,
      most: json['most'] ?? defaultData.most,
    );
  }
}

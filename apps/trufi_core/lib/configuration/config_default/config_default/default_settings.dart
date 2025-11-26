import 'package:trufi_core/localization/app_localization.dart';

enum BicycleParkingFilter { all, freeOnly, securePreferred }

BicycleParkingFilter getBicycleParkingFilter(String key) {
  return BicycleParkingFilterExtension.names.keys.firstWhere(
    (keyE) => keyE.name == key,
    orElse: () => BicycleParkingFilter.all,
  );
}

extension BicycleParkingFilterExtension on BicycleParkingFilter {
  static const names = <BicycleParkingFilter, String>{
    BicycleParkingFilter.all: "all",
    BicycleParkingFilter.freeOnly: "freeOnly",
    BicycleParkingFilter.securePreferred: "securePreferred",
  };

  String get name => names[this] ?? "all";

  String translateValue(AppLocalization localization) {
    switch (this) {
      case BicycleParkingFilter.all:
        return 'localization.bicycleParkingFilterAll';
      case BicycleParkingFilter.freeOnly:
        return 'localization.bicycleParkingFilterFreeOnly';
      case BicycleParkingFilter.securePreferred:
        return 'localization.bicycleParkingFilterSecurePreferred';
      // ignore: unreachable_switch_default
      default:
        return 'typeError';
    }
  }
}

class DefaultSettings {
  static final defaultData = DefaultSettings(
    optimize: null,
    safetyFactor: null,
    slopeFactor: null,
    timeFactor: null,
    accessibilityOption: false,
    bikeSpeed: 5.55,
    bicycleParkingFilter: BicycleParkingFilter.all,
    ticketTypes: 'none',
    walkBoardCost: 600,
    walkReluctance: 2.0,
    walkSpeed: 1.2,
    includeBikeSuggestions: true,
    includeParkAndRideSuggestions: false,
    includeCarSuggestions: false,
    showBikeAndParkItineraries: false,
  );

  String? optimize;
  double? safetyFactor;
  double? slopeFactor;
  double? timeFactor;
  bool accessibilityOption;
  double bikeSpeed;
  BicycleParkingFilter bicycleParkingFilter;
  String ticketTypes;
  int walkBoardCost;
  double walkReluctance;
  double walkSpeed;
  bool includeBikeSuggestions;
  bool includeParkAndRideSuggestions;
  bool includeCarSuggestions;
  bool showBikeAndParkItineraries;

  DefaultSettings({
    this.optimize,
    this.safetyFactor,
    this.slopeFactor,
    this.timeFactor,
    this.accessibilityOption = false,
    this.bikeSpeed = 5.55,
    this.bicycleParkingFilter = BicycleParkingFilter.all,
    this.ticketTypes = 'none',
    this.walkBoardCost = 600,
    this.walkReluctance = 2.0,
    this.walkSpeed = 1.2,
    this.includeBikeSuggestions = true,
    this.includeParkAndRideSuggestions = false,
    this.includeCarSuggestions = false,
    this.showBikeAndParkItineraries = false,
  });

  factory DefaultSettings.fromJson(Map<String, dynamic> json) {
    return DefaultSettings(
      optimize: json['optimize'],
      safetyFactor: (json['safetyFactor']),
      slopeFactor: (json['slopeFactor']),
      timeFactor: (json['timeFactor']),
      accessibilityOption: json['accessibilityOption'] ?? false,
      bikeSpeed: (json['bikeSpeed']) ?? 5.55,
      bicycleParkingFilter: getBicycleParkingFilter(
        json['bicycleParkingFilter'] ?? 'all',
      ),
      ticketTypes: json['ticketTypes'] ?? 'none',
      walkBoardCost: json['walkBoardCost'] ?? 600,
      walkReluctance: (json['walkReluctance']) ?? 2.0,
      walkSpeed: (json['walkSpeed']) ?? 1.2,
      includeBikeSuggestions: json['includeBikeSuggestions'] ?? true,
      includeParkAndRideSuggestions:
          json['includeParkAndRideSuggestions'] ?? false,
      includeCarSuggestions: json['includeCarSuggestions'] ?? false,
      showBikeAndParkItineraries: json['showBikeAndParkItineraries'] ?? false,
    );
  }
}

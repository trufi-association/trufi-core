/// Interface for a place in a journey.
abstract class IPlace {
  String get name;
  double get lat;
  double get lon;
}

/// Interface for route information.
abstract class IRouteInfo {
  String get id;
  String? get shortName;
  String? get longName;
  String? get color;
  String? get textColor;
}

/// Interface for a leg (segment) of a journey.
abstract class ILeg {
  String get points;
  double get distance;
  Duration get duration;
  IPlace get toPlace;
  IPlace get fromPlace;
  DateTime get startTime;
  DateTime get endTime;
  bool get transitLeg;
}

/// Interface for an itinerary (complete journey option).
abstract class IItinerary {
  List<ILeg> get legs;
  DateTime get startTime;
  DateTime get endTime;
  Duration get duration;
  Duration get walkTime;
  double get distance;
  double get walkDistance;
  int get transfers;
}

/// Interface for a journey plan (collection of itineraries).
abstract class IPlan {
  List<IItinerary>? get itineraries;
  bool get hasError;
  String? get errorMessage;
}

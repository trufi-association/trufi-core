part of 'plan.dart';

class Itinerary extends Equatable {
  static const String _legs = "legs";
  static const String _startTime = "startTime";
  static const String _endTime = "endTime";
  static const String _duration = "duration";
  static const String _walkTime = "walkTime";
  static const String _walkDistance = "walkDistance";

  final List<Leg> legs;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final Duration walkTime;
  final double distance;
  final double walkDistance;

  Itinerary({
    required this.legs,
    required this.startTime,
    required this.endTime,
    required this.walkTime,
    required this.duration,
    required this.walkDistance,
  }) : distance = sumDistances(legs);

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      legs: json[_legs]?.map<Leg>((dynamic json) {
            return Leg.fromJson(json as Map<String, dynamic>);
          }).toList() as List<Leg>? ??
          [],
      startTime: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json[_startTime].toString()) ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json[_endTime].toString()) ?? 0),
      duration:
          Duration(seconds: int.tryParse(json[_duration].toString()) ?? 0),
      walkTime:
          Duration(seconds: int.tryParse(json[_walkTime].toString()) ?? 0),
      walkDistance: double.tryParse(json[_walkDistance].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _legs: legs.map((itinerary) => itinerary.toJson()).toList(),
      _startTime: startTime.millisecondsSinceEpoch,
      _endTime: endTime.millisecondsSinceEpoch,
      _duration: duration.inSeconds,
      _walkTime: walkTime.inSeconds,
      _walkDistance: walkDistance,
    };
  }

  Itinerary copyWith({
    List<Leg>? legs,
    DateTime? startTime,
    DateTime? endTime,
    Duration? walkTime,
    Duration? duration,
    double? walkDistance,
  }) {
    return Itinerary(
      legs: legs ?? this.legs,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      walkTime: walkTime ?? this.walkTime,
      duration: duration ?? this.duration,
      walkDistance: walkDistance ?? this.walkDistance,
    );
  }

  List<Leg> get compressLegs {
    final compressedLegs = <Leg>[];
    Leg? compressedLeg;
    for (final Leg currentLeg in legs) {
      if (compressedLeg == null) {
        compressedLeg = currentLeg.copyWith();
        continue;
      }

      if (continueWithNoTransit(compressedLeg, currentLeg)) {
        compressedLeg = compressedLeg.copyWith(
          duration: compressedLeg.duration + currentLeg.duration,
          distance: compressedLeg.distance + currentLeg.distance,
          toPlace: currentLeg.toPlace,
          endTime: currentLeg.endTime,
          transportMode: TransportMode.bicycle,
          accumulatedPoints: [
            ...compressedLeg.accumulatedPoints,
            ...currentLeg.accumulatedPoints
          ],
        );
        continue;
      }

      compressedLegs.add(compressedLeg);
      compressedLeg = currentLeg.copyWith();
    }
    if (compressedLeg != null) {
      compressedLegs.add(compressedLeg);
    }

    return compressedLegs;
  }

  String startDateText(TrufiBaseLocalization localization) {
    final tempDate = DateTime.now();
    final nowDate = DateTime(tempDate.year, tempDate.month, tempDate.day);
    if (nowDate.difference(startTime).inDays == 0) {
      return '';
    }
    if (nowDate.difference(startTime).inDays == 1) {
      return localization.commonTomorrow;
    }
    return DateFormat('E dd.MM.', localization.localeName).format(startTime);
  }

  String get startTimeHHmm => durationToHHmm(startTime);

  String get endTimeHHmm => durationToHHmm(endTime);

  String getDistanceString(TrufiBaseLocalization localization) =>
      distanceWithTranslation(localization, distance.toDouble());

  String durationFormat(TrufiBaseLocalization localization) =>
      durationFormatString(localization, duration);

  String getWalkDistanceString(TrufiBaseLocalization localization) =>
      distanceWithTranslation(localization, walkDistance.toDouble());

  double get totalBikingDistance => getTotalBikingDistance(compressLegs);

  Duration get totalBikingDuration => getTotalBikingDuration(compressLegs);

  String firstLegStartTime(TrufiBaseLocalization localization) {
    final firstTransport = getFirstDeparture;
    String legStartTime = '';
    if (firstTransport != null) {
      final String firstDepartureStopType =
          firstTransport.transportMode == TransportMode.rail ||
                  firstTransport.transportMode == TransportMode.subway
              ? localization.commonFromStation
              : localization.commonFromStop;
      legStartTime =
          "${localization.commonLeavesAt} $firstDepartureStopType ${firstTransport.fromPlace.name}";
    } else {
      legStartTime = localization.commonItineraryNoTransitLegs;
    }

    return legStartTime;
  }

  Leg? get getFirstDeparture {
    final firstDeparture = compressLegs.firstWhereOrNull(
      (element) => element.transitLeg,
    );
    return firstDeparture;
  }

  int getNumberLegHide(double renderBarThreshold) {
    return compressLegs
        .where((leg) {
          final legLength = (leg.duration.inSeconds / duration.inSeconds) * 10;
          return legLength < renderBarThreshold &&
              leg.transportMode != TransportMode.walk;
        })
        .toList()
        .length;
  }

  int getNumberLegTime(double renderBarThreshold) {
    return compressLegs.fold(0, (previousValue, leg) {
      final legLength = (leg.duration.inSeconds / duration.inSeconds) * 10;
      return legLength < renderBarThreshold
          ? previousValue + leg.duration.inSeconds
          : previousValue;
    });
  }

  @override
  List<Object?> get props => [
        legs,
        distance,
        startTime,
        endTime,
        walkTime,
        duration,
        walkDistance,
      ];
}

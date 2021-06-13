part of 'plan_entity.dart';

class PlanItinerary {
  static const String _legs = "legs";
  static const String _startTime = "startTime";
  static const String _endTime = "endTime";
  static const String _walkTime = "walkTime";
  static const String _durationTrip = "duration";
  static const String _walkDistance = "walkDistance";

  static int _distanceForLegs(List<PlanItineraryLeg> legs) =>
      legs.fold<int>(0, (distance, leg) => distance += leg.distance.ceil());

  static int _timeForLegs(List<PlanItineraryLeg> legs) =>
      (legs.fold<double>(0, (time, leg) => time += leg.duration) / 60).ceil();

  PlanItinerary({
    this.legs,
    this.startTime,
    this.endTime,
    this.walkTime,
    this.durationTrip,
    this.walkDistance,
  })  : distance = _distanceForLegs(legs),
        time = _timeForLegs(legs);

  final List<PlanItineraryLeg> legs;
  final DateTime startTime;
  final DateTime endTime;
  final Duration walkTime;
  final Duration durationTrip;
  final double walkDistance;
  // add

  final int distance;
  final int time;

  factory PlanItinerary.fromJson(Map<String, dynamic> json) {
    return PlanItinerary(
        legs: json[_legs].map<PlanItineraryLeg>((dynamic json) {
          return PlanItineraryLeg.fromJson(json as Map<String, dynamic>);
        }).toList() as List<PlanItineraryLeg>,
        startTime: json[_startTime] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                int.tryParse(json[_startTime].toString()) ?? 0)
            : null,
        endTime: json[_endTime] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                int.tryParse(json[_endTime].toString()) ?? 0)
            : null,
        walkTime: json[_walkTime] != null
            ? Duration(seconds: json[_walkTime] as int)
            : null,
        durationTrip: json[_durationTrip] != null
            ? Duration(seconds: json[_durationTrip] as int)
            : null,
        walkDistance: double.tryParse(json[_walkDistance].toString()) ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      _legs: legs.map((itinerary) => itinerary.toJson()).toList(),
      _startTime: startTime?.millisecondsSinceEpoch,
      _endTime: endTime?.millisecondsSinceEpoch,
      _walkTime: walkTime?.inSeconds,
      _durationTrip: durationTrip?.inSeconds,
      _walkDistance: walkDistance
    };
  }

  PlanItinerary copyWith({
    List<PlanItineraryLeg> legs,
    DateTime startTime,
    DateTime endTime,
    Duration walkTime,
    Duration durationTrip,
    double walkDistance,
  }) {
    return PlanItinerary(
      legs: legs ?? this.legs,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      walkTime: walkTime ?? this.walkTime,
      durationTrip: durationTrip ?? this.durationTrip,
      walkDistance: walkDistance ?? this.walkDistance,
    );
  }

  List<PlanItineraryLeg> get compressLegs {
    final usingOwnBicycle = legs.any(
      (leg) =>
          getLegModeByKey(leg.transportMode.name) == LegMode.bicycle &&
          leg.rentedBike == false,
    );
    final compressedLegs = <PlanItineraryLeg>[];
    PlanItineraryLeg compressedLeg;
    for (final PlanItineraryLeg currentLeg in legs) {
      if (compressedLeg == null) {
        compressedLeg = currentLeg.copyWith();
        continue;
      }
      if (currentLeg.intermediatePlaces != null) {
        compressedLegs.add(compressedLeg);
        compressedLeg = currentLeg.copyWith();
        continue;
      }

      if (usingOwnBicycle && continueWithBicycle(compressedLeg, currentLeg)) {
        final newBikePark = compressedLeg?.toPlace?.bikeParkEntity ??
            currentLeg?.toPlace?.bikeParkEntity;
        compressedLeg = compressedLeg.copyWith(
          duration: compressedLeg.duration + currentLeg.duration,
          distance: compressedLeg.distance + currentLeg.distance,
          toPlace: currentLeg.toPlace.copyWith(bikeParkEntity: newBikePark),
          endTime: currentLeg.endTime,
          mode: TransportMode.bicycle.name,
          accumulatedPoints: [
            ...compressedLeg.accumulatedPoints,
            ...currentLeg.accumulatedPoints
          ],
        );
        continue;
      }

      if (currentLeg.rentedBike != null &&
          continueWithRentedBicycle(compressedLeg, currentLeg) &&
          !bikingEnded(currentLeg)) {
        compressedLeg = compressedLeg.copyWith(
          duration: compressedLeg.duration + currentLeg.duration,
          distance: compressedLeg.distance + currentLeg.distance,
          toPlace: currentLeg.toPlace,
          endTime: currentLeg.endTime,
          mode: LegMode.bicycle.name,
          accumulatedPoints: [
            ...compressedLeg.accumulatedPoints,
            ...currentLeg.accumulatedPoints
          ],
        );
        continue;
      }

      if (usingOwnBicycle &&
          getLegModeByKey(compressedLeg.mode) == LegMode.walk) {
        compressedLeg = compressedLeg.copyWith(
          mode: LegMode.bicycleWalk.name,
        );
      }

      compressedLegs.add(compressedLeg);
      compressedLeg = currentLeg.copyWith();

      if (usingOwnBicycle && getLegModeByKey(currentLeg.mode) == LegMode.walk) {
        compressedLeg = compressedLeg.copyWith(
          mode: LegMode.bicycleWalk.name,
        );
      }
    }
    if (compressedLeg != null) {
      compressedLegs.add(compressedLeg);
    }

    return compressedLegs;
  }

  String futureText(TrufiLocalization localization) {
    final tempDate = DateTime.now();
    final nowDate = DateTime(tempDate.year, tempDate.month, tempDate.day);

    if (startTime.difference(nowDate).inDays == 0) {
      return '';
    }
    if (startTime.difference(nowDate).inDays == 1) {
      return localization.commonTomorrow;
    }
    return DateFormat('E dd.MM.', localization.localeName).format(startTime);
  }

  bool get hasAdvencedData =>
      startTime != null &&
      endTime != null &&
      walkTime != null &&
      durationTrip != null &&
      walkDistance != null;

  String get startTimeHHmm => durationToHHmm(startTime);

  String get endTimeHHmm => durationToHHmm(endTime);

  String getDistanceString(TrufiLocalization localization) =>
      displayDistanceWithLocale(localization, distance.toDouble());

  String durationTripString(TrufiLocalization localization) =>
      durationToString(localization, durationTrip);

  String getWalkDistanceString(TrufiLocalization localization) =>
      displayDistanceWithLocale(localization, walkDistance.toDouble());

  double get totalDistance => sumDistances(legs);

  double get totalWalkingDistance =>
      getTotalWalkingDistance(compressLegs ?? []);

  double get totalBikingDistance => getTotalBikingDistance(compressLegs ?? []);

  Duration get totalWalkingDuration =>
      Duration(seconds: getTotalWalkingDuration(compressLegs ?? []).toInt());

  Duration get totalBikingDuration =>
      Duration(seconds: getTotalBikingDuration(compressLegs ?? []).toInt());

  String firstLegStartTime(TrufiLocalization localization) {
    final firstDeparture = compressLegs.firstWhere(
      (element) => element.transitLeg ?? false,
      orElse: () => null,
    );
    String legStartTime = '';
    if (firstDeparture != null) {
      if (firstDeparture?.rentedBike ?? false) {
        legStartTime = localization.departureBikeStation(
          firstDeparture?.startTimeString,
          firstDeparture?.fromPlace?.name,
        );
        if (firstDeparture?.fromPlace?.bikeRentalStation?.bikesAvailable !=
            null) {
          legStartTime =
              '$legStartTime ${firstDeparture.fromPlace.bikeRentalStation.bikesAvailable} ${localization.commonBikesAvailable}';
        }
      } else {
        final String firstDepartureStopType =
            firstDeparture.transportMode == TransportMode.rail ||
                    firstDeparture.transportMode == TransportMode.subway
                ? localization.commonFromStation
                : localization.commonFromStop;
        final String firstDeparturePlatform =
            firstDeparture?.fromPlace?.stopEntity?.platformCode != null
                ? (firstDeparture.transportMode == TransportMode.rail
                        ? ', ${localization.commonTrack} '
                        : ', ${localization.commonPlatform} ') +
                    firstDeparture?.fromPlace?.stopEntity?.platformCode
                : '';
        legStartTime =
            "${localization.commonLeavesAt} ${firstDeparture.startTimeString} $firstDepartureStopType ${firstDeparture.fromPlace.name} $firstDeparturePlatform";
      }
    } else {
      legStartTime = localization.commonItineraryNoTransitLegs;
    }

    return legStartTime;
  }

  int get totalDurationItinerary {
    return endTime.difference(startTime).inSeconds;
  }

  double get durationItinerary {
    final duration = endTime.difference(startTime).inSeconds;
    return duration + numberRouteHidens;
  }

  bool get usingOwnBicycle => legs.any((leg) =>
      leg.transportMode == TransportMode.bicycle && leg.rentedBike ?? false);

  bool get renderModeIcons => compressLegs.length < 10;

  bool get usingOwnBicycleWholeTrip {
    return usingOwnBicycle &&
        legs.every((leg) => leg.toPlace?.bikeParkEntity == null);
  }

  double get numberRouteHidens {
    double sumPart = 0;
    final routeShorts = compressLegs.where((leg) {
      final legLength = (leg.durationIntLeg / totalDurationItinerary) * 100;
      if (legLength < 9.3 &&
          (leg.transitLeg || leg.transportMode == TransportMode.walk)) {
        sumPart += legLength;
      }
      if (leg.toPlace?.bikeParkEntity != null &&
          leg.toPlace?.carParkEntity != null &&
          leg.toPlace?.bikeParkEntity != null) {
        sumPart -= 22;
      }
      return legLength < 9.3 &&
          (leg.transitLeg || leg.transportMode == TransportMode.walk);
    }).toList();
    return (((routeShorts.length * 9.3) - sumPart) * totalDurationItinerary) /
        100;
  }
}

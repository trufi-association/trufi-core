class TrufiLocation {
  final String description;
  final double latitude;
  final double longitude;

  TrufiLocation({this.description, this.latitude, this.longitude});

  factory TrufiLocation.fromJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['description'],
      latitude: json['lat'],
      longitude: json['lng'],
    );
  }

  String toString() {
    return '$latitude,$longitude';
  }
}

class Plan {
  final int date;
  final PlanLocation from;
  final PlanLocation to;
  final List<PlanItinerary> itineraries;

  Plan({this.date, this.from, this.to, this.itineraries});

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
        date: json['date'],
        from: PlanLocation.fromJson(json['from']),
        to: PlanLocation.fromJson(json['to']),
        itineraries: json['itineraries']
            .map<PlanItinerary>((json) => new PlanItinerary.fromJson(json))
            .toList());
  }
}

class PlanLocation {
  final String name;
  final double latitude;
  final double longitude;

  PlanLocation({this.name, this.latitude, this.longitude});

  factory PlanLocation.fromJson(Map<String, dynamic> json) {
    return PlanLocation(
        name: json['name'], latitude: json['lat'], longitude: json['lon']);
  }
}

class PlanItinerary {
  final int duration;
  final int startTime;
  final int endTime;
  final int walkTime;
  final int transitTime;
  final int waitingTime;
  final double walkDistance;
  final bool walkLimitExceeded;
  final double elevationLost;
  final double elevationGained;
  final int transfers;
  final List<PlanItineraryLeg> legs;

  PlanItinerary(
      {this.duration,
      this.startTime,
      this.endTime,
      this.walkTime,
      this.transitTime,
      this.waitingTime,
      this.walkDistance,
      this.walkLimitExceeded,
      this.elevationLost,
      this.elevationGained,
      this.transfers,
      this.legs});

  factory PlanItinerary.fromJson(Map<String, dynamic> json) {
    return new PlanItinerary(
        duration: json['duration'],
        startTime: json['startTime'],
        endTime: json['endTime'],
        walkTime: json['walkTime'],
        transitTime: json['transitTime'],
        waitingTime: json['waitingTime'],
        walkDistance: json['walkDistance'],
        walkLimitExceeded: json['walkLimitExceeded'],
        elevationLost: json['elevationLost'],
        elevationGained: json['elevationGained'],
        transfers: json['transfers'],
        legs: json['legs']
            .map<PlanItineraryLeg>(
                (json) => new PlanItineraryLeg.fromJson(json))
            .toList());
  }
}

class PlanItineraryLeg {
  final String points;

  PlanItineraryLeg({this.points});

  factory PlanItineraryLeg.fromJson(Map<String, dynamic> json) {
    return new PlanItineraryLeg(points: json['legGeometry']['points']);
  }
}

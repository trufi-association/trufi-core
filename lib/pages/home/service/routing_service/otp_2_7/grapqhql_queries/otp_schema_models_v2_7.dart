import 'package:flutter/foundation.dart';
import 'package:trufi_core/models/enums/transport_mode.dart';
import 'package:trufi_core/models/enums/vertex_type.dart';
import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/models/trufi_map_utils.dart';

extension EnumParsing<T extends Enum> on Iterable<T> {
  T? fromString(String? value) {
    if (value == null) return null;
    try {
      return firstWhere((e) => e.toString().split('.').last == value);
    } catch (_) {
      return null;
    }
  }
}

enum AbsoluteDirection {
  north,
  northeast,
  east,
  southeast,
  south,
  southwest,
  west,
  northwest,
}

enum AlternativeLegsFilter {
  noFilter,
  sameAuthority,
  sameMode,
  sameSubmode,
  sameLine,
}

enum ArrivalDeparture { arrivals, departures, both }

enum BikesAllowed { noInformation, allowed, notAllowed }

enum BicycleOptimisationMethod { quick, safe, flat, greenways, triangle }

enum BookingMethod { callDriver, callOffice, online, phoneAtStop, text }

enum DirectionType { unknown, outbound, inbound, clockwise, anticlockwise }

enum FilterPlaceType { quay, stopPlace, bicycleRent, bikePark, carPark }

enum InputField { dateTime, from, to, intermediatePlace }

enum InterchangePriority { preferred, recommended, allowed, notAllowed }

enum InterchangeWeighting {
  preferredInterchange,
  recommendedInterchange,
  interchangeAllowed,
  noInterchange,
}

enum ItineraryFilterDebugProfile {
  off,
  listAll,
  limitToSearchWindow,
  limitToNumOfItineraries,
}

enum Locale { no, us }

enum Mode {
  air,
  bicycle,
  bus,
  cableway,
  water,
  funicular,
  lift,
  rail,
  metro,
  taxi,
  tram,
  trolleybus,
  monorail,
  coach,
  foot,
  car,
  scooter,
}

extension ModeExtension on Mode {
  static const _modeToOtpStringMap = {
    Mode.air: "AIRPLANE",
    Mode.bicycle: "BICYCLE",
    Mode.bus: "BUS",
    Mode.cableway: "GONDOLA",
    Mode.water: "FERRY",
    Mode.funicular: "FUNICULAR",
    Mode.lift: "CABLE_CAR",
    Mode.rail: "RAIL",
    Mode.metro: "SUBWAY",
    Mode.taxi: "CAR",
    Mode.tram: "TRAM",
    Mode.trolleybus: "TROLLEYBUS",
    Mode.monorail: "MONORAIL",
    Mode.coach: "BUS",
    Mode.foot: "WALK",
    Mode.car: "CAR",
    Mode.scooter: "BICYCLE",
  };
  String toOtpString() => _modeToOtpStringMap[this] ?? '';
}

enum OccupancyStatus {
  noData,
  empty,
  manySeatsAvailable,
  fewSeatsAvailable,
  standingRoomOnly,
  crushedStandingRoomOnly,
  full,
  notAcceptingPassengers,
}

enum MultiModalMode { parent, child, all }

enum PurchaseWhen {
  timeOfTravelOnly,
  dayOfTravelOnly,
  untilPreviousDay,
  advanceAndDayOfTravel,
  other,
}

enum RealtimeState { scheduled, updated, canceled, Added, modified }

enum RelativeDirection {
  depart,
  hardLeft,
  left,
  slightlyLeft,
  // "continue" is a reserved keyword in Dart.
  // We use "goStraight" instead for clarity.
  goStraight,
  slightlyRight,
  right,
  hardRight,
  circleClockwise,
  circleCounterclockwise,
  elevator,
  uturnLeft,
  uturnRight,
  enterStation,
  exitStation,
  followSigns,
}

enum ReportType { general, incident }

enum RoutingErrorCode {
  locationNotFound,
  noStopsInRange,
  noTransitConnection,
  noTransitConnectionInSearchWindow,
  outsideBounds,
  outsideServicePeriod,
  walkingBetterThanTransit,
}

enum ServiceAlteration { cancellation, replaced, extraJourney, planned }

enum Severity {
  unknown,
  noImpact,
  verySlight,
  slight,
  normal,
  severe,
  verySevere,
  undefined,
}

enum StopCondition {
  destination,
  startPoint,
  exceptionalStop,
  notStopping,
  requestStop,
}

enum StopInterchangePriority { preferred, recommended, allowed, discouraged }

enum StreetMode {
  foot,
  bicycle,
  bike_park,
  bike_rental,
  scooter_rental,
  car,
  car_park,
  car_pickup,
  car_rental,
  flexible,
}

enum TransportMode {
  air,
  bus,
  cableway,
  water,
  funicular,
  lift,
  rail,
  metro,
  taxi,
  tram,
  trolleybus,
  monorail,
  coach,
  unknown,
}

enum TransportSubmode {
  unknown,
  undefined,
  internationalFlight,
  domesticFlight,
  intercontinentalFlight,
  domesticScheduledFlight,
  shuttleFlight,
  intercontinentalCharterFlight,
  internationalCharterFlight,
  roundTripCharterFlight,
  sightseeingFlight,
  helicopterService,
  domesticCharterFlight,
  SchengenAreaFlight,
  airshipService,
  shortHaulInternationalFlight,
  canalBarge,
  localBus,
  regionalBus,
  expressBus,
  nightBus,
  postBus,
  specialNeedsBus,
  mobilityBus,
  mobilityBusForRegisteredDisabled,
  sightseeingBus,
  shuttleBus,
  highFrequencyBus,
  dedicatedLaneBus,
  schoolBus,
  schoolAndPublicServiceBus,
  railReplacementBus,
  demandAndResponseBus,
  airportLinkBus,
  internationalCoach,
  nationalCoach,
  shuttleCoach,
  regionalCoach,
  specialCoach,
  schoolCoach,
  sightseeingCoach,
  touristCoach,
  commuterCoach,
  funicular,
  streetCableCar,
  allFunicularServices,
  undefinedFunicular,
  metro,
  tube,
  urbanRailway,
  cityTram,
  localTram,
  regionalTram,
  sightseeingTram,
  shuttleTram,
  trainTram,
  telecabin,
  cableCar,
  lift,
  chairLift,
  dragLift,
  telecabinLink,
  local,
  highSpeedRail,
  suburbanRailway,
  regionalRail,
  interregionalRail,
  longDistance,
  international,
  sleeperRailService,
  nightRail,
  carTransportRailService,
  touristRailway,
  airportLinkRail,
  railShuttle,
  replacementRailService,
  specialTrain,
  crossCountryRail,
  rackAndPinionRailway,
  internationalCarFerry,
  nationalCarFerry,
  regionalCarFerry,
  localCarFerry,
  internationalPassengerFerry,
  nationalPassengerFerry,
  regionalPassengerFerry,
  localPassengerFerry,
  postBoat,
  trainFerry,
  roadFerryLink,
  airportBoatLink,
  highSpeedVehicleService,
  highSpeedPassengerService,
  sightseeingService,
  schoolBoat,
  cableFerry,
  riverBus,
  scheduledFerry,
  shuttleFerryService,
  communalTaxi,
  charterTaxi,
  waterTaxi,
  railTaxi,
  bikeTaxi,
  blackCab,
  miniCab,
  allTaxiServices,
  hireCar,
  hireVan,
  hireMotorbike,
  hireCycle,
  allHireVehicles,
}

enum VertexType27 { normal, transit, bikePark, bikeShare }

extension VertexTypeToLegacy on VertexType27 {
  VertexTypeTrufi toVertexType() {
    switch (this) {
      case VertexType27.normal:
        return VertexTypeTrufi.normal;
      case VertexType27.transit:
        return VertexTypeTrufi.transit;
      case VertexType27.bikePark:
        return VertexTypeTrufi.bikepark;
      case VertexType27.bikeShare:
        return VertexTypeTrufi.bikeshare;
    }
  }
}

enum WheelchairBoarding { noInformation, notPossible, possible }

@immutable
class BookingArrangement {
  final List<BookingMethod?>? bookingMethods;
  final String? latestBookingTime;
  final int? latestBookingDay;
  final PurchaseWhen? bookWhen;
  final String? minimumBookingPeriod;
  final String? bookingNote;
  final Contact? bookingContact;
  const BookingArrangement({
    this.bookingMethods,
    this.latestBookingTime,
    this.latestBookingDay,
    this.bookWhen,
    this.minimumBookingPeriod,
    this.bookingNote,
    this.bookingContact,
  });

  factory BookingArrangement.fromJson(Map<String, dynamic> json) =>
      BookingArrangement(
        bookingMethods: (json['bookingMethods'] as List?)
            ?.map((e) => BookingMethod.values.fromString(e))
            .toList(),
        latestBookingTime: json['latestBookingTime'],
        latestBookingDay: json['latestBookingDay'],
        bookWhen: PurchaseWhen.values.fromString(json['bookWhen']),
        minimumBookingPeriod: json['minimumBookingPeriod'],
        bookingNote: json['bookingNote'],
        bookingContact: json['bookingContact'] != null
            ? Contact.fromJson(json['bookingContact'])
            : null,
      );
}

@immutable
class Branding {
  final String? id;
  final String? name;
  final String? shortName;
  final String? description;
  final String? url;
  final String? image;

  const Branding({
    this.id,
    this.name,
    this.shortName,
    this.description,
    this.url,
    this.image,
  });

  factory Branding.fromJson(Map<String, dynamic> json) => Branding(
    id: json['id'],
    name: json['name'],
    shortName: json['shortName'],
    description: json['description'],
    url: json['url'],
    image: json['image'],
  );
}

@immutable
class Authority {
  final String? id;
  final String? name;
  final String? url;
  final String? timezone;
  final String? lang;
  final String? phone;
  final String? fareUrl;
  final List<Line>? lines;
  final List<PtSituationElement>? situations;
  const Authority({
    this.id,
    this.name,
    this.url,
    this.timezone,
    this.lang,
    this.phone,
    this.fareUrl,
    this.lines,
    this.situations,
  });

  factory Authority.fromJson(Map<String, dynamic> json) => Authority(
    id: json['id'],
    name: json['name'],
    url: json['url'],
    timezone: json['timezone'],
    lang: json['lang'],
    phone: json['phone'],
    fareUrl: json['fareUrl'],
    lines: (json['lines'] as List?)?.map((e) => Line.fromJson(e)).toList(),
    situations: (json['situations'] as List?)
        ?.map((e) => PtSituationElement.fromJson(e))
        .toList(),
  );
}

@immutable
class AffectedLine {
  final Line? line;

  const AffectedLine({this.line});

  factory AffectedLine.fromJson(Map<String, dynamic> json) => AffectedLine(
    line: json['line'] != null ? Line.fromJson(json['line']) : null,
  );
}

@immutable
class AffectedServiceJourney {
  final ServiceJourney? serviceJourney;
  final String? operatingDay;
  final DatedServiceJourney? datedServiceJourney;

  const AffectedServiceJourney({
    this.serviceJourney,
    this.operatingDay,
    this.datedServiceJourney,
  });

  factory AffectedServiceJourney.fromJson(Map<String, dynamic> json) =>
      AffectedServiceJourney(
        serviceJourney: json['serviceJourney'] != null
            ? ServiceJourney.fromJson(json['serviceJourney'])
            : null,
        operatingDay: json['operatingDay'],
        datedServiceJourney: json['datedServiceJourney'] != null
            ? DatedServiceJourney.fromJson(json['datedServiceJourney'])
            : null,
      );
}

@immutable
class AffectedStopPlace {
  final Quay? quay;
  final StopPlace? stopPlace;
  final List<StopCondition?>? stopConditions;
  const AffectedStopPlace({this.quay, this.stopPlace, this.stopConditions});

  factory AffectedStopPlace.fromJson(Map<String, dynamic> json) =>
      AffectedStopPlace(
        quay: json['quay'] != null ? Quay.fromJson(json['quay']) : null,
        stopPlace: json['stopPlace'] != null
            ? StopPlace.fromJson(json['stopPlace'])
            : null,
        stopConditions: (json['stopConditions'] as List?)
            ?.map((e) => StopCondition.values.fromString(e))
            .toList(),
      );
}

@immutable
class AffectedStopPlaceOnLine {
  final Quay? quay;
  final StopPlace? stopPlace;
  final Line? line;
  final List<StopCondition?>? stopConditions;

  const AffectedStopPlaceOnLine({
    this.quay,
    this.stopPlace,
    this.line,
    this.stopConditions,
  });

  factory AffectedStopPlaceOnLine.fromJson(Map<String, dynamic> json) =>
      AffectedStopPlaceOnLine(
        quay: json['quay'] != null ? Quay.fromJson(json['quay']) : null,
        stopPlace: json['stopPlace'] != null
            ? StopPlace.fromJson(json['stopPlace'])
            : null,
        line: json['line'] != null ? Line.fromJson(json['line']) : null,
        stopConditions: (json['stopConditions'] as List?)
            ?.map((e) => StopCondition.values.fromString(e))
            .toList(),
      );
}

@immutable
class AffectedStopPlaceOnServiceJourney {
  final Quay? quay;
  final StopPlace? stopPlace;
  final ServiceJourney? serviceJourney;
  final String? operatingDay;
  final DatedServiceJourney? datedServiceJourney;
  final List<StopCondition?>? stopConditions;
  const AffectedStopPlaceOnServiceJourney({
    this.quay,
    this.stopPlace,
    this.serviceJourney,
    this.operatingDay,
    this.datedServiceJourney,
    this.stopConditions,
  });

  factory AffectedStopPlaceOnServiceJourney.fromJson(
    Map<String, dynamic> json,
  ) => AffectedStopPlaceOnServiceJourney(
    quay: json['quay'] != null ? Quay.fromJson(json['quay']) : null,
    stopPlace: json['stopPlace'] != null
        ? StopPlace.fromJson(json['stopPlace'])
        : null,
    serviceJourney: json['serviceJourney'] != null
        ? ServiceJourney.fromJson(json['serviceJourney'])
        : null,
    operatingDay: json['operatingDay'],
    datedServiceJourney: json['datedServiceJourney'] != null
        ? DatedServiceJourney.fromJson(json['datedServiceJourney'])
        : null,
    stopConditions: (json['stopConditions'] as List?)
        ?.map((e) => StopCondition.values.fromString(e))
        .toList(),
  );
}

@immutable
class AffectedUnknown {
  final String? description;

  const AffectedUnknown({this.description});

  factory AffectedUnknown.fromJson(Map<String, dynamic> json) =>
      AffectedUnknown(description: json['description']);
}

@immutable
class BikePark {
  final String? id;
  final String? name;
  final int? spacesAvailable;
  final bool? realtime;
  final double? longitude;
  final double? latitude;

  const BikePark({
    this.id,
    this.name,
    this.spacesAvailable,
    this.realtime,
    this.longitude,
    this.latitude,
  });

  factory BikePark.fromJson(Map<String, dynamic> json) => BikePark(
    id: json['id'],
    name: json['name'],
    spacesAvailable: json['spacesAvailable'],
    realtime: json['realtime'],
    longitude: json['longitude'],
    latitude: json['latitude'],
  );
}

@immutable
class BikeRentalStation {
  final String? id;
  final String? name;
  final int? bikesAvailable;
  final int? spacesAvailable;
  final bool? realtimeOccupancyAvailable;
  final bool? allowDropoff;
  final List<String>? networks;
  final double? longitude;
  final double? latitude;
  const BikeRentalStation({
    this.id,
    this.name,
    this.bikesAvailable,
    this.spacesAvailable,
    this.realtimeOccupancyAvailable,
    this.allowDropoff,
    this.networks,
    this.longitude,
    this.latitude,
  });

  factory BikeRentalStation.fromJson(Map<String, dynamic> json) =>
      BikeRentalStation(
        id: json['id'],
        name: json['name'],
        bikesAvailable: json['bikesAvailable'],
        spacesAvailable: json['spacesAvailable'],
        realtimeOccupancyAvailable: json['realtimeOccupancyAvailable'],
        allowDropoff: json['allowDropoff'],
        networks: (json['networks'] as List?)
            ?.map((e) => e.toString())
            .toList(),
        longitude: json['longitude'],
        latitude: json['latitude'],
      );

  BikeRentalStationEntity toBikeRentalStation() {
    return BikeRentalStationEntity(
      id: id,
      stationId: null,
      name: name,
      bikesAvailable: bikesAvailable,
      spacesAvailable: spacesAvailable,
      state: null,
      realtime: realtimeOccupancyAvailable,
      allowDropoff: allowDropoff,
      networks: networks,
      lon: longitude,
      lat: latitude,
      capacity: null,
      allowOverloading: allowDropoff,
    );
  }
}

@immutable
class Contact {
  final String? contactPerson;
  final String? email;
  final String? url;
  final String? phone;
  final String? furtherDetails;

  const Contact({
    this.contactPerson,
    this.email,
    this.url,
    this.phone,
    this.furtherDetails,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    contactPerson: json['contactPerson'],
    email: json['email'],
    url: json['url'],
    phone: json['phone'],
    furtherDetails: json['furtherDetails'],
  );
}

@immutable
class DatedServiceJourney {
  final String? id;
  final String? operatingDay;
  final ServiceJourney? serviceJourney;
  final ServiceAlteration? tripAlteration;
  final List<DatedServiceJourney>? replacementFor;
  final JourneyPattern? journeyPattern;
  final List<Quay>? quays;
  final List<EstimatedCall>? estimatedCalls;

  const DatedServiceJourney({
    this.id,
    this.operatingDay,
    this.serviceJourney,
    this.tripAlteration,
    this.replacementFor,
    this.journeyPattern,
    this.quays,
    this.estimatedCalls,
  });

  factory DatedServiceJourney.fromJson(Map<String, dynamic> json) =>
      DatedServiceJourney(
        id: json['id'],
        operatingDay: json['operatingDay'],
        serviceJourney: json['serviceJourney'] != null
            ? ServiceJourney.fromJson(json['serviceJourney'])
            : null,
        tripAlteration: ServiceAlteration.values.fromString(
          json['tripAlteration'],
        ),
        replacementFor: (json['replacementFor'] as List?)
            ?.map((e) => DatedServiceJourney.fromJson(e))
            .toList(),
        journeyPattern: json['journeyPattern'] != null
            ? JourneyPattern.fromJson(json['journeyPattern'])
            : null,
        quays: (json['quays'] as List?)?.map((e) => Quay.fromJson(e)).toList(),
        estimatedCalls: (json['estimatedCalls'] as List?)
            ?.map((e) => EstimatedCall.fromJson(e))
            .toList(),
      );
}

@immutable
class DdebugOutput {
  final int? totalTime;

  const DdebugOutput({this.totalTime});

  factory DdebugOutput.fromJson(Map<String, dynamic> json) =>
      DdebugOutput(totalTime: json['totalTime']);
}

@immutable
class DestinationDisplay {
  final String? frontText;
  final List<String>? via;
  const DestinationDisplay({this.frontText, this.via});

  factory DestinationDisplay.fromJson(Map<String, dynamic> json) =>
      DestinationDisplay(
        frontText: json['frontText'],
        via: (json['via'] as List?)?.map((e) => e.toString()).toList(),
      );
}

@immutable
class ElevationProfileStep {
  final double? distance;
  final double? elevation;

  const ElevationProfileStep({this.distance, this.elevation});

  factory ElevationProfileStep.fromJson(Map<String, dynamic> json) =>
      ElevationProfileStep(
        distance: json['distance'],
        elevation: json['elevation'],
      );
}

@immutable
class EstimatedCall {
  final Quay? quay;
  final String? aimedArrivalTime;
  final String? expectedArrivalTime;
  final String? actualArrivalTime;
  final String? aimedDepartureTime;
  final String? expectedDepartureTime;
  final String? actualDepartureTime;
  final bool? timingPoint;
  final bool? realtime;
  final bool? predictionInaccurate;
  final RealtimeState? realtimeState;
  final OccupancyStatus? occupancyStatus;
  final int? stopPositionInPattern;
  final bool? forBoarding;
  final bool? forAlighting;
  final bool? requestStop;
  final bool? cancellation;
  final String? date;
  final ServiceJourney? serviceJourney;
  final DatedServiceJourney? datedServiceJourney;
  final DestinationDisplay? destinationDisplay;
  final List<Notice>? notices;
  final List<PtSituationElement>? situations;
  final BookingArrangement? bookingArrangements;
  const EstimatedCall({
    this.quay,
    this.aimedArrivalTime,
    this.expectedArrivalTime,
    this.actualArrivalTime,
    this.aimedDepartureTime,
    this.expectedDepartureTime,
    this.actualDepartureTime,
    this.timingPoint,
    this.realtime,
    this.predictionInaccurate,
    this.realtimeState,
    this.occupancyStatus,
    this.stopPositionInPattern,
    this.forBoarding,
    this.forAlighting,
    this.requestStop,
    this.cancellation,
    this.date,
    this.serviceJourney,
    this.datedServiceJourney,
    this.destinationDisplay,
    this.notices,
    this.situations,
    this.bookingArrangements,
  });

  factory EstimatedCall.fromJson(Map<String, dynamic> json) => EstimatedCall(
    quay: json['quay'] != null ? Quay.fromJson(json['quay']) : null,
    aimedArrivalTime: json['aimedArrivalTime'],
    expectedArrivalTime: json['expectedArrivalTime'],
    actualArrivalTime: json['actualArrivalTime'],
    aimedDepartureTime: json['aimedDepartureTime'],
    expectedDepartureTime: json['expectedDepartureTime'],
    actualDepartureTime: json['actualDepartureTime'],
    timingPoint: json['timingPoint'],
    realtime: json['realtime'],
    predictionInaccurate: json['predictionInaccurate'],
    realtimeState: RealtimeState.values.fromString(json['realtimeState']),
    occupancyStatus: OccupancyStatus.values.fromString(json['occupancyStatus']),
    stopPositionInPattern: json['stopPositionInPattern'],
    forBoarding: json['forBoarding'],
    forAlighting: json['forAlighting'],
    requestStop: json['requestStop'],
    cancellation: json['cancellation'],
    date: json['date'],
    serviceJourney: json['serviceJourney'] != null
        ? ServiceJourney.fromJson(json['serviceJourney'])
        : null,
    datedServiceJourney: json['datedServiceJourney'] != null
        ? DatedServiceJourney.fromJson(json['datedServiceJourney'])
        : null,
    destinationDisplay: json['destinationDisplay'] != null
        ? DestinationDisplay.fromJson(json['destinationDisplay'])
        : null,
    notices: (json['notices'] as List?)
        ?.map((e) => Notice.fromJson(e))
        .toList(),
    situations: (json['situations'] as List?)
        ?.map((e) => PtSituationElement.fromJson(e))
        .toList(),
    bookingArrangements: json['bookingArrangements'] != null
        ? BookingArrangement.fromJson(json['bookingArrangements'])
        : null,
  );
}

@immutable
class GroupOfLines {
  final String? id;
  final String? privateCode;
  final String? shortName;
  final String? name;
  final String? description;
  final List<Line>? lines;
  const GroupOfLines({
    this.id,
    this.privateCode,
    this.shortName,
    this.name,
    this.description,
    this.lines,
  });

  factory GroupOfLines.fromJson(Map<String, dynamic> json) => GroupOfLines(
    id: json['id'],
    privateCode: json['privateCode'],
    shortName: json['shortName'],
    name: json['name'],
    description: json['description'],
    lines: (json['lines'] as List?)?.map((e) => Line.fromJson(e)).toList(),
  );
}

@immutable
class InfoLink {
  final String? uri;
  final String? label;

  const InfoLink({this.uri, this.label});

  factory InfoLink.fromJson(Map<String, dynamic> json) =>
      InfoLink(uri: json['uri'], label: json['label']);
}

@immutable
class InputBanned {
  const InputBanned({
    this.lines,
    this.authorities,
    this.quays,
    this.quaysHard,
    this.serviceJourneys,
    this.rentalNetworks,
  });

  factory InputBanned.fromJson(Map<String, dynamic> json) => InputBanned(
    lines: (json['lines'] as List?)?.map((e) => e.toString()).toList(),
    authorities: (json['authorities'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    quays: (json['quays'] as List?)?.map((e) => e.toString()).toList(),
    quaysHard: (json['quaysHard'] as List?)?.map((e) => e.toString()).toList(),
    serviceJourneys: (json['serviceJourneys'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    rentalNetworks: (json['rentalNetworks'] as List?)
        ?.map((e) => e.toString())
        .toList(),
  );

  final List<String>? lines;
  final List<String>? authorities;
  final List<String>? quays;
  final List<String>? quaysHard;
  final List<String>? serviceJourneys;
  final List<String>? rentalNetworks;
}

@immutable
class InputCoordinates {
  final double? latitude;
  final double? longitude;

  const InputCoordinates({this.latitude, this.longitude});

  factory InputCoordinates.fromJson(Map<String, dynamic> json) =>
      InputCoordinates(
        latitude: json['latitude'],
        longitude: json['longitude'],
      );
}

@immutable
class InputPlaceIds {
  const InputPlaceIds({
    this.quays,
    this.lines,
    this.bikeRentalStations,
    this.bikeParks,
    this.carParks,
  });

  factory InputPlaceIds.fromJson(Map<String, dynamic> json) => InputPlaceIds(
    quays: (json['quays'] as List?)?.map((e) => e.toString()).toList(),
    lines: (json['lines'] as List?)?.map((e) => e.toString()).toList(),
    bikeRentalStations: (json['bikeRentalStations'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    bikeParks: (json['bikeParks'] as List?)?.map((e) => e.toString()).toList(),
    carParks: (json['carParks'] as List?)?.map((e) => e.toString()).toList(),
  );

  final List<String>? quays;
  final List<String>? lines;
  final List<String>? bikeRentalStations;
  final List<String>? bikeParks;
  final List<String>? carParks;
}

@immutable
class InputWhiteListed {
  final List<String>? lines;
  final List<String>? authorities;
  final List<String>? rentalNetworks;
  const InputWhiteListed({this.lines, this.authorities, this.rentalNetworks});

  factory InputWhiteListed.fromJson(Map<String, dynamic> json) =>
      InputWhiteListed(
        lines: (json['lines'] as List?)?.map((e) => e.toString()).toList(),
        authorities: (json['authorities'] as List?)
            ?.map((e) => e.toString())
            .toList(),
        rentalNetworks: (json['rentalNetworks'] as List?)
            ?.map((e) => e.toString())
            .toList(),
      );
}

@immutable
class Interchange {
  final bool? staySeated;
  final bool? guaranteed;
  final InterchangePriority? priority;
  final int? maximumWaitTime;
  final ServiceJourney? fromServiceJourney;
  final ServiceJourney? toServiceJourney;

  const Interchange({
    this.staySeated,
    this.guaranteed,
    this.priority,
    this.maximumWaitTime,
    this.fromServiceJourney,
    this.toServiceJourney,
  });

  factory Interchange.fromJson(Map<String, dynamic> json) => Interchange(
    staySeated: json['staySeated'],
    guaranteed: json['guaranteed'],
    priority: InterchangePriority.values.fromString(json['priority']),
    maximumWaitTime: json['maximumWaitTime'],
    fromServiceJourney: json['fromServiceJourney'] != null
        ? ServiceJourney.fromJson(json['fromServiceJourney'])
        : null,
    toServiceJourney: json['toServiceJourney'] != null
        ? ServiceJourney.fromJson(json['toServiceJourney'])
        : null,
  );
}

@immutable
class ItineraryFilters {
  final TransitGeneralizedCostFilterParams? transitGeneralizedCostLimit;
  final double? groupSimilarityKeepOne;
  final double? groupSimilarityKeepThree;
  final double? groupedOtherThanSameLegsMaxCostMultiplier;
  final ItineraryFilterDebugProfile? debug;

  const ItineraryFilters({
    this.transitGeneralizedCostLimit,
    this.groupSimilarityKeepOne,
    this.groupSimilarityKeepThree,
    this.groupedOtherThanSameLegsMaxCostMultiplier,
    this.debug,
  });

  factory ItineraryFilters.fromJson(Map<String, dynamic> json) =>
      ItineraryFilters(
        transitGeneralizedCostLimit: json['transitGeneralizedCostLimit'] != null
            ? TransitGeneralizedCostFilterParams.fromJson(
                json['transitGeneralizedCostLimit'],
              )
            : null,
        groupSimilarityKeepOne: json['groupSimilarityKeepOne'],
        groupSimilarityKeepThree: json['groupSimilarityKeepThree'],
        groupedOtherThanSameLegsMaxCostMultiplier:
            json['groupedOtherThanSameLegsMaxCostMultiplier'],
        debug: ItineraryFilterDebugProfile.values.fromString(json['debug']),
      );
}

@immutable
class JourneyPattern {
  final String? id;
  final Line? line;
  final DirectionType? directionType;
  final String? name;
  final List<ServiceJourney>? serviceJourneys;
  final List<Quay>? quays;
  final PointsOnLink? pointsOnLink;
  final List<StopToStopGeometry>? stopToStopGeometries;
  final List<PtSituationElement>? situations;
  final List<Notice>? notices;
  const JourneyPattern({
    this.id,
    this.line,
    this.directionType,
    this.name,
    this.serviceJourneys,
    this.quays,
    this.pointsOnLink,
    this.stopToStopGeometries,
    this.situations,
    this.notices,
  });

  factory JourneyPattern.fromJson(Map<String, dynamic> json) => JourneyPattern(
    id: json['id'],
    line: json['line'] != null ? Line.fromJson(json['line']) : null,
    directionType: DirectionType.values.fromString(json['directionType']),
    name: json['name'],
    serviceJourneys: (json['serviceJourneys'] as List?)
        ?.map((e) => ServiceJourney.fromJson(e))
        .toList(),
    quays: (json['quays'] as List?)?.map((e) => Quay.fromJson(e)).toList(),
    pointsOnLink: json['pointsOnLink'] != null
        ? PointsOnLink.fromJson(json['pointsOnLink'])
        : null,
    stopToStopGeometries: (json['stopToStopGeometries'] as List?)
        ?.map((e) => StopToStopGeometry.fromJson(e))
        .toList(),
    situations: (json['situations'] as List?)
        ?.map((e) => PtSituationElement.fromJson(e))
        .toList(),
    notices: (json['notices'] as List?)
        ?.map((e) => Notice.fromJson(e))
        .toList(),
  );
}

@immutable
class Leg {
  final String? id;
  final String? aimedStartTime;
  final String? expectedStartTime;
  final String? aimedEndTime;
  final String? expectedEndTime;
  final Mode? mode;
  final TransportSubmode? transportSubmode;
  final int? duration;
  final int? directDuration;
  final PointsOnLink? pointsOnLink;
  final Authority? authority;
  final Operator? operator;
  final bool? realtime;
  final double? distance;
  final int? generalizedCost;
  final bool? ride;
  final bool? walkingBike;
  final bool? rentedBike;
  final Place? fromPlace;
  final Place? toPlace;
  final EstimatedCall? fromEstimatedCall;
  final EstimatedCall? toEstimatedCall;
  final Line? line;
  final ServiceJourney? serviceJourney;
  final DatedServiceJourney? datedServiceJourney;
  final String? serviceDate;
  final List<Quay>? intermediateQuays;
  final List<EstimatedCall>? intermediateEstimatedCalls;
  final List<EstimatedCall>? serviceJourneyEstimatedCalls;
  final List<PtSituationElement>? situations;
  final List<PathGuidance>? steps;
  final Interchange? interchangeFrom;
  final Interchange? interchangeTo;
  final BookingArrangement? bookingArrangements;
  final List<String>? bikeRentalNetworks;
  final List<ElevationProfileStep>? elevationProfile;
  const Leg({
    this.id,
    this.aimedStartTime,
    this.expectedStartTime,
    this.aimedEndTime,
    this.expectedEndTime,
    this.mode,
    this.transportSubmode,
    this.duration,
    this.directDuration,
    this.pointsOnLink,
    this.authority,
    this.operator,
    this.realtime,
    this.distance,
    this.generalizedCost,
    this.ride,
    this.walkingBike,
    this.rentedBike,
    this.fromPlace,
    this.toPlace,
    this.fromEstimatedCall,
    this.toEstimatedCall,
    this.line,
    this.serviceJourney,
    this.datedServiceJourney,
    this.serviceDate,
    this.intermediateQuays,
    this.intermediateEstimatedCalls,
    this.serviceJourneyEstimatedCalls,
    this.situations,
    this.steps,
    this.interchangeFrom,
    this.interchangeTo,
    this.bookingArrangements,
    this.bikeRentalNetworks,
    this.elevationProfile,
  });

  factory Leg.fromJson(Map<String, dynamic> json) => Leg(
    id: json['id'],
    aimedStartTime: json['aimedStartTime'],
    expectedStartTime: json['expectedStartTime'],
    aimedEndTime: json['aimedEndTime'],
    expectedEndTime: json['expectedEndTime'],
    mode: Mode.values.fromString(json['mode']),
    transportSubmode: TransportSubmode.values.fromString(
      json['transportSubmode'],
    ),
    duration: json['duration'],
    directDuration: json['directDuration'],
    pointsOnLink: json['pointsOnLink'] != null
        ? PointsOnLink.fromJson(json['pointsOnLink'])
        : null,
    authority: json['authority'] != null
        ? Authority.fromJson(json['authority'])
        : null,
    operator: json['operator'] != null
        ? Operator.fromJson(json['operator'])
        : null,
    realtime: json['realtime'],
    distance: json['distance'],
    generalizedCost: json['generalizedCost'],
    ride: json['ride'],
    walkingBike: json['walkingBike'],
    rentedBike: json['rentedBike'],
    fromPlace: json['fromPlace'] != null
        ? Place.fromJson(json['fromPlace'])
        : null,
    toPlace: json['toPlace'] != null ? Place.fromJson(json['toPlace']) : null,
    fromEstimatedCall: json['fromEstimatedCall'] != null
        ? EstimatedCall.fromJson(json['fromEstimatedCall'])
        : null,
    toEstimatedCall: json['toEstimatedCall'] != null
        ? EstimatedCall.fromJson(json['toEstimatedCall'])
        : null,
    line: json['line'] != null ? Line.fromJson(json['line']) : null,
    serviceJourney: json['serviceJourney'] != null
        ? ServiceJourney.fromJson(json['serviceJourney'])
        : null,
    datedServiceJourney: json['datedServiceJourney'] != null
        ? DatedServiceJourney.fromJson(json['datedServiceJourney'])
        : null,
    serviceDate: json['serviceDate'],
    intermediateQuays: (json['intermediateQuays'] as List?)
        ?.map((e) => Quay.fromJson(e))
        .toList(),
    intermediateEstimatedCalls: (json['intermediateEstimatedCalls'] as List?)
        ?.map((e) => EstimatedCall.fromJson(e))
        .toList(),
    serviceJourneyEstimatedCalls:
        (json['serviceJourneyEstimatedCalls'] as List?)
            ?.map((e) => EstimatedCall.fromJson(e))
            .toList(),
    situations: (json['situations'] as List?)
        ?.map((e) => PtSituationElement.fromJson(e))
        .toList(),
    steps: (json['steps'] as List?)
        ?.map((e) => PathGuidance.fromJson(e))
        .toList(),
    interchangeFrom: json['interchangeFrom'] != null
        ? Interchange.fromJson(json['interchangeFrom'])
        : null,
    interchangeTo: json['interchangeTo'] != null
        ? Interchange.fromJson(json['interchangeTo'])
        : null,
    bookingArrangements: json['bookingArrangements'] != null
        ? BookingArrangement.fromJson(json['bookingArrangements'])
        : null,
    bikeRentalNetworks: (json['bikeRentalNetworks'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    elevationProfile: (json['elevationProfile'] as List?)
        ?.map((e) => ElevationProfileStep.fromJson(e))
        .toList(),
  );

  PlanItineraryLeg toPlanItineraryLeg() {
    return PlanItineraryLeg(
      points: pointsOnLink?.points ?? '',
      mode: mode?.toOtpString() ?? '',
      route: line?.toRouteEntity(),
      shortName: line?.publicCode,
      startTime: DateTime.tryParse(expectedStartTime ?? '') ?? DateTime(1000),
      endTime: DateTime.tryParse(expectedEndTime ?? '') ?? DateTime(1000),
      distance: distance ?? 0,
      duration: Duration(seconds: duration ?? 0),
      routeLongName: line?.operator?.name ?? '', // route?.longName ?? '',
      agency: null, //agency?.toAgencyEntity(),
      toPlace: toPlace?.toPlaceEntity(),
      fromPlace: fromPlace?.toPlaceEntity(),
      intermediatePlaces: intermediateQuays
          ?.map(
            (e) => PlaceEntity(
              name: e.name ?? '',
              vertexType: VertexTypeTrufi.normal,
              lat: e.latitude ?? 0,
              lon: e.longitude ?? 0,
              arrivalTime: DateTime(2000),
              departureTime: DateTime(2000),
              stopEntity: null,
              bikeRentalStation: null,
              bikeParkEntity: null,
              carParkEntity: null,
              vehicleParkingWithEntrance: null,
            ),
          )
          .toList(),
      pickupBookingInfo: null, // pickupBookingInfo,
      dropOffBookingInfo: null, //  dropOffBookingInfo,
      rentedBike: rentedBike,
      intermediatePlace: null, // intermediatePlace,
      transitLeg: ride ?? false, // transitLeg ?? false,
      interlineWithPreviousLeg: null, // interlineWithPreviousLeg,
      accumulatedPoints: pointsOnLink?.points != null
          ? TrufiMapUtils.decodePolyline(pointsOnLink?.points)
          : [],
      trip: null, //trip,
    );
  }
}

@immutable
class Line {
  final String? id;
  final Authority? authority;
  final Operator? operator;
  final Branding? branding;
  final String? publicCode;
  final String? name;
  final TransportMode? transportMode;
  final TransportSubmode? transportSubmode;
  final String? description;
  final String? url;
  final Presentation? presentation;
  final BikesAllowed? bikesAllowed;
  final List<JourneyPattern>? journeyPatterns;
  final List<Quay>? quays;
  final List<ServiceJourney>? serviceJourneys;
  final List<Notice>? notices;
  final List<PtSituationElement>? situations;
  final String? flexibleLineType;
  final List<GroupOfLines>? groupOfLines;
  const Line({
    this.id,
    this.authority,
    this.operator,
    this.branding,
    this.publicCode,
    this.name,
    this.transportMode,
    this.transportSubmode,
    this.description,
    this.url,
    this.presentation,
    this.bikesAllowed,
    this.journeyPatterns,
    this.quays,
    this.serviceJourneys,
    this.notices,
    this.situations,
    this.flexibleLineType,
    this.groupOfLines,
  });

  factory Line.fromJson(Map<String, dynamic> json) => Line(
    id: json['id'],
    authority: json['authority'] != null
        ? Authority.fromJson(json['authority'])
        : null,
    operator: json['operator'] != null
        ? Operator.fromJson(json['operator'])
        : null,
    branding: json['branding'] != null
        ? Branding.fromJson(json['branding'])
        : null,
    publicCode: json['publicCode'],
    name: json['name'],
    transportMode: TransportMode.values.fromString(json['transportMode']),
    transportSubmode: TransportSubmode.values.fromString(
      json['transportSubmode'],
    ),
    description: json['description'],
    url: json['url'],
    presentation: json['presentation'] != null
        ? Presentation.fromJson(json['presentation'])
        : null,
    bikesAllowed: BikesAllowed.values.fromString(json['bikesAllowed']),
    journeyPatterns: (json['journeyPatterns'] as List?)
        ?.map((e) => JourneyPattern.fromJson(e))
        .toList(),
    quays: (json['quays'] as List?)?.map((e) => Quay.fromJson(e)).toList(),
    serviceJourneys: (json['serviceJourneys'] as List?)
        ?.map((e) => ServiceJourney.fromJson(e))
        .toList(),
    notices: (json['notices'] as List?)
        ?.map((e) => Notice.fromJson(e))
        .toList(),
    situations: (json['situations'] as List?)
        ?.map((e) => PtSituationElement.fromJson(e))
        .toList(),
    flexibleLineType: json['flexibleLineType'],
    groupOfLines: (json['groupOfLines'] as List?)
        ?.map((e) => GroupOfLines.fromJson(e))
        .toList(),
  );
  RouteEntity toRouteEntity() {
    return RouteEntity(
      id: id,
      gtfsId: null,
      agency: null, //agency?.toAgencyEntity(),
      shortName: publicCode,
      longName: publicCode,
      // TODO review TransportMode
      mode: getTransportMode(mode: transportMode?.name ?? ''),
      type: null, //type,
      desc: description,
      url: url,
      color: presentation?.colour,
      textColor: presentation?.textColour,
    );
  }
}

@immutable
class Location {
  final String? name;
  final String? place;
  final InputCoordinates? coordinates;

  const Location({this.name, this.place, this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    name: json['name'],
    place: json['place'],
    coordinates: json['coordinates'] != null
        ? InputCoordinates.fromJson(json['coordinates'])
        : null,
  );
}

@immutable
class Modes {
  const Modes({
    this.accessMode,
    this.egressMode,
    this.directMode,
    this.transportModes,
  });
  final StreetMode? accessMode;
  final StreetMode? egressMode;
  final StreetMode? directMode;
  final List<TransportModes>? transportModes;

  factory Modes.fromJson(Map<String, dynamic> json) => Modes(
    accessMode: StreetMode.values.fromString(json['accessMode']),
    egressMode: StreetMode.values.fromString(json['egressMode']),
    directMode: StreetMode.values.fromString(json['directMode']),
    transportModes: (json['transportModes'] as List?)
        ?.map((e) => TransportModes.fromJson(e))
        .toList(),
  );
}

@immutable
class MultilingualString {
  final String? value;
  final String? language;

  const MultilingualString({this.value, this.language});

  factory MultilingualString.fromJson(Map<String, dynamic> json) =>
      MultilingualString(value: json['value'], language: json['language']);
}

@immutable
class Notice {
  final String? id;
  final String? text;
  final String? publicCode;

  const Notice({this.id, this.text, this.publicCode});

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
    id: json['id'],
    text: json['text'],
    publicCode: json['publicCode'],
  );
}

@immutable
class Operator {
  final String? id;
  final String? name;
  final String? url;
  final String? phone;
  final List<Line>? lines;
  final List<ServiceJourney>? serviceJourney;
  const Operator({
    this.id,
    this.name,
    this.url,
    this.phone,
    this.lines,
    this.serviceJourney,
  });

  factory Operator.fromJson(Map<String, dynamic> json) => Operator(
    id: json['id'],
    name: json['name'],
    url: json['url'],
    phone: json['phone'],
    lines: (json['lines'] as List?)?.map((e) => Line.fromJson(e)).toList(),
    serviceJourney: (json['serviceJourney'] as List?)
        ?.map((e) => ServiceJourney.fromJson(e))
        .toList(),
  );
}

@immutable
class PageInfo {
  final bool? hasNextPage;
  final bool? hasPreviousPage;
  final String? startCursor;
  final String? endCursor;

  const PageInfo({
    this.hasNextPage,
    this.hasPreviousPage,
    this.startCursor,
    this.endCursor,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
    hasNextPage: json['hasNextPage'],
    hasPreviousPage: json['hasPreviousPage'],
    startCursor: json['startCursor'],
    endCursor: json['endCursor'],
  );
}

@immutable
class PassThroughPoint {
  final String? name;
  final List<String>? placeIds;
  const PassThroughPoint({this.name, this.placeIds});

  factory PassThroughPoint.fromJson(Map<String, dynamic> json) =>
      PassThroughPoint(
        name: json['name'],
        placeIds: (json['placeIds'] as List?)
            ?.map((e) => e.toString())
            .toList(),
      );
}

@immutable
class PathGuidance {
  final double? distance;
  final RelativeDirection? relativeDirection;
  final String? streetName;
  final AbsoluteDirection? heading;
  final String? exit;
  final bool? stayOn;
  final bool? area;
  final bool? bogusName;
  final double? latitude;
  final double? longitude;
  final List<ElevationProfileStep>? elevationProfile;
  const PathGuidance({
    this.distance,
    this.relativeDirection,
    this.streetName,
    this.heading,
    this.exit,
    this.stayOn,
    this.area,
    this.bogusName,
    this.latitude,
    this.longitude,
    this.elevationProfile,
  });

  factory PathGuidance.fromJson(Map<String, dynamic> json) => PathGuidance(
    distance: json['distance'],
    relativeDirection: RelativeDirection.values.fromString(
      json['relativeDirection'],
    ),
    streetName: json['streetName'],
    heading: AbsoluteDirection.values.fromString(json['heading']),
    exit: json['exit'],
    stayOn: json['stayOn'],
    area: json['area'],
    bogusName: json['bogusName'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    elevationProfile: (json['elevationProfile'] as List?)
        ?.map((e) => ElevationProfileStep.fromJson(e))
        .toList(),
  );
}

@immutable
class PenaltyForStreetMode {
  final StreetMode? streetMode;
  // final DoubleFunction? timePenalty;
  final double? costFactor;

  const PenaltyForStreetMode({
    this.streetMode,
    // this.timePenalty,
    this.costFactor,
  });

  factory PenaltyForStreetMode.fromJson(
    Map<String, dynamic> json,
  ) => PenaltyForStreetMode(
    streetMode: StreetMode.values.fromString(json['streetMode']),
    // timePenalty: json['timePenalty'] != null ? DoubleFunction.fromJson(json['timePenalty']) : null,
    costFactor: json['costFactor'],
  );
}

@immutable
class Coordinate {
  final double? lat;
  final double? lon;

  const Coordinate({this.lat, this.lon});

  factory Coordinate.fromJson(Map<String, dynamic> json) =>
      Coordinate(lat: json['lat'], lon: json['lon']);
}

class Place {
  final String? name;
  final VertexType27? vertexType;
  final double? latitude;
  final double? longitude;
  final Quay? quay;
  final String? flexibleArea;
  final BikeRentalStation? bikeRentalStation;
  final RentalVehicle? rentalVehicle;
  const Place({
    this.name,
    this.vertexType,
    this.latitude,
    this.longitude,
    this.quay,
    this.flexibleArea,
    this.bikeRentalStation,
    this.rentalVehicle,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    name: json['name'],
    vertexType: VertexType27.values.fromString(json['vertexType']),
    latitude: json['latitude'],
    longitude: json['longitude'],
    quay: json['quay'] != null ? Quay.fromJson(json['quay']) : null,
    flexibleArea: json['flexibleArea'],
    bikeRentalStation: json['bikeRentalStation'] != null
        ? BikeRentalStation.fromJson(json['bikeRentalStation'])
        : null,
    rentalVehicle: json['rentalVehicle'] != null
        ? RentalVehicle.fromJson(json['rentalVehicle'])
        : null,
  );

  PlanLocation toPlanLocation() {
    return PlanLocation(name: name, latitude: latitude, longitude: longitude);
  }

  PlaceEntity toPlaceEntity() {
    return PlaceEntity(
      name: name ?? '',
      // TODO review default value VertexType.normal
      vertexType: vertexType?.toVertexType() ?? VertexTypeTrufi.normal,
      lat: latitude ?? 0,
      lon: longitude ?? 0,
      arrivalTime:
          null, // DateTime.fromMillisecondsSinceEpoch(arrivalTime?.toInt() ?? 0),
      departureTime:
          null, // DateTime.fromMillisecondsSinceEpoch(departureTime?.toInt() ?? 0),
      stopEntity: null, //stop?.toStopEntity(),
      bikeRentalStation: bikeRentalStation?.toBikeRentalStation(),
      bikeParkEntity: null, //bikePark?.toBikeParkEntity(),
      carParkEntity: null, //carPark?.toCarParkEntity(),
      vehicleParkingWithEntrance: null, //vehicleParkingWithEntrance,
    );
  }
}

@immutable
class PlaceAtDistance {
  final double? distance;

  const PlaceAtDistance({this.distance});

  factory PlaceAtDistance.fromJson(Map<String, dynamic> json) =>
      PlaceAtDistance(distance: json['distance']);
}

@immutable
class PlaceAtDistanceConnection {
  final List<PlaceAtDistanceEdge>? edges;
  final PageInfo? pageInfo;
  const PlaceAtDistanceConnection({this.edges, this.pageInfo});

  factory PlaceAtDistanceConnection.fromJson(Map<String, dynamic> json) =>
      PlaceAtDistanceConnection(
        edges: (json['edges'] as List?)
            ?.map((e) => PlaceAtDistanceEdge.fromJson(e))
            .toList(),
        pageInfo: json['pageInfo'] != null
            ? PageInfo.fromJson(json['pageInfo'])
            : null,
      );
}

@immutable
class PlaceAtDistanceEdge {
  final PlaceAtDistance? node;
  final String? cursor;

  const PlaceAtDistanceEdge({this.node, this.cursor});

  factory PlaceAtDistanceEdge.fromJson(Map<String, dynamic> json) =>
      PlaceAtDistanceEdge(
        node: json['node'] != null
            ? PlaceAtDistance.fromJson(json['node'])
            : null,
        cursor: json['cursor'],
      );
}

@immutable
class PointsOnLink {
  final int? length;
  final String? points;

  const PointsOnLink({this.length, this.points});

  factory PointsOnLink.fromJson(Map<String, dynamic> json) =>
      PointsOnLink(length: json['length'], points: json['points']);
}

@immutable
class Presentation {
  final String? colour;
  final String? textColour;

  const Presentation({this.colour, this.textColour});

  factory Presentation.fromJson(Map<String, dynamic> json) =>
      Presentation(colour: json['colour'], textColour: json['textColour']);
}

@immutable
class PtSituationElement {
  final String? id;
  final List<MultilingualString>? summary;
  final List<MultilingualString>? description;
  final List<MultilingualString>? advice;
  final List<InfoLink>? infoLinks;
  final ValidityPeriod? validityPeriod;
  final ReportType? reportType;
  final String? situationNumber;
  final Severity? severity;
  final int? priority;
  final String? creationTime;
  final String? versionedAtTime;
  final int? version;
  final String? participant;
  const PtSituationElement({
    this.id,
    this.summary,
    this.description,
    this.advice,
    this.infoLinks,
    this.validityPeriod,
    this.reportType,
    this.situationNumber,
    this.severity,
    this.priority,
    this.creationTime,
    this.versionedAtTime,
    this.version,
    this.participant,
  });

  factory PtSituationElement.fromJson(Map<String, dynamic> json) =>
      PtSituationElement(
        id: json['id'],
        summary: (json['summary'] as List?)
            ?.map((e) => MultilingualString.fromJson(e))
            .toList(),
        description: (json['description'] as List?)
            ?.map((e) => MultilingualString.fromJson(e))
            .toList(),
        advice: (json['advice'] as List?)
            ?.map((e) => MultilingualString.fromJson(e))
            .toList(),
        infoLinks: (json['infoLinks'] as List?)
            ?.map((e) => InfoLink.fromJson(e))
            .toList(),
        validityPeriod: json['validityPeriod'] != null
            ? ValidityPeriod.fromJson(json['validityPeriod'])
            : null,
        reportType: ReportType.values.fromString(json['reportType']),
        situationNumber: json['situationNumber'],
        severity: Severity.values.fromString(json['severity']),
        priority: json['priority'],
        creationTime: json['creationTime'],
        versionedAtTime: json['versionedAtTime'],
        version: json['version'],
        participant: json['participant'],
      );
}

@immutable
class Quay {
  final String? id;
  final String? name;
  final double? latitude;
  final double? longitude;
  final String? description;
  final StopPlace? stopPlace;
  final WheelchairBoarding? wheelchairAccessible;
  final String? timeZone;
  final String? publicCode;
  final List<Line>? lines;
  final List<JourneyPattern>? journeyPatterns;
  final List<EstimatedCall>? estimatedCalls;
  final List<PtSituationElement>? situations;
  final String? stopType;
  final String? flexibleArea;
  final List<Quay>? flexibleGroup;
  final List<TariffZone>? tariffZones;

  const Quay({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.description,
    this.stopPlace,
    this.wheelchairAccessible,
    this.timeZone,
    this.publicCode,
    this.lines,
    this.journeyPatterns,
    this.estimatedCalls,
    this.situations,
    this.stopType,
    this.flexibleArea,
    this.flexibleGroup,
    this.tariffZones,
  });

  factory Quay.fromJson(Map<String, dynamic> json) => Quay(
    id: json['id'],
    name: json['name'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    description: json['description'],
    stopPlace: json['stopPlace'] != null
        ? StopPlace.fromJson(json['stopPlace'])
        : null,
    wheelchairAccessible: WheelchairBoarding.values.fromString(
      json['wheelchairAccessible'],
    ),
    timeZone: json['timeZone'],
    publicCode: json['publicCode'],
    lines: (json['lines'] as List?)?.map((e) => Line.fromJson(e)).toList(),
    journeyPatterns: (json['journeyPatterns'] as List?)
        ?.map((e) => JourneyPattern.fromJson(e))
        .toList(),
    estimatedCalls: (json['estimatedCalls'] as List?)
        ?.map((e) => EstimatedCall.fromJson(e))
        .toList(),
    situations: (json['situations'] as List?)
        ?.map((e) => PtSituationElement.fromJson(e))
        .toList(),
    stopType: json['stopType'],
    flexibleArea: json['flexibleArea'],
    flexibleGroup: (json['flexibleGroup'] as List?)
        ?.map((e) => Quay.fromJson(e))
        .toList(),
    tariffZones: (json['tariffZones'] as List?)
        ?.map((e) => TariffZone.fromJson(e))
        .toList(),
  );
}

@immutable
class QuayAtDistance {
  final String? id;
  final Quay? quay;
  final double? distance;

  const QuayAtDistance({this.id, this.quay, this.distance});

  factory QuayAtDistance.fromJson(Map<String, dynamic> json) => QuayAtDistance(
    id: json['id'],
    quay: json['quay'] != null ? Quay.fromJson(json['quay']) : null,
    distance: json['distance'],
  );
}

@immutable
class QuayAtDistanceConnection {
  const QuayAtDistanceConnection({this.edges, this.pageInfo});

  factory QuayAtDistanceConnection.fromJson(Map<String, dynamic> json) =>
      QuayAtDistanceConnection(
        edges: (json['edges'] as List?)
            ?.map((e) => QuayAtDistanceEdge.fromJson(e))
            .toList(),
        pageInfo: json['pageInfo'] != null
            ? PageInfo.fromJson(json['pageInfo'])
            : null,
      );

  final List<QuayAtDistanceEdge>? edges;
  final PageInfo? pageInfo;
}

@immutable
class QuayAtDistanceEdge {
  final QuayAtDistance? node;
  final String? cursor;

  const QuayAtDistanceEdge({this.node, this.cursor});

  factory QuayAtDistanceEdge.fromJson(Map<String, dynamic> json) =>
      QuayAtDistanceEdge(
        node: json['node'] != null
            ? QuayAtDistance.fromJson(json['node'])
            : null,
        cursor: json['cursor'],
      );
}

@immutable
class RelaxCostInput {
  final double? ratio;
  final String? constant;

  const RelaxCostInput({this.ratio, this.constant});

  factory RelaxCostInput.fromJson(Map<String, dynamic> json) =>
      RelaxCostInput(ratio: json['ratio'], constant: json['constant']);
}

@immutable
class RentalVehicle {
  final String? id;
  final RentalVehicleType? vehicleType;
  final String? network;
  final double? longitude;
  final double? latitude;
  final double? currentRangeMeters;

  const RentalVehicle({
    this.id,
    this.vehicleType,
    this.network,
    this.longitude,
    this.latitude,
    this.currentRangeMeters,
  });

  factory RentalVehicle.fromJson(Map<String, dynamic> json) => RentalVehicle(
    id: json['id'],
    vehicleType: json['vehicleType'] != null
        ? RentalVehicleType.fromJson(json['vehicleType'])
        : null,
    network: json['network'],
    longitude: json['longitude'],
    latitude: json['latitude'],
    currentRangeMeters: json['currentRangeMeters'],
  );
}

@immutable
class RentalVehicleType {
  final String? vehicleTypeId;
  final String? name;
  final String? formFactor;
  final String? propulsionType;
  final double? maxRangeMeters;

  const RentalVehicleType({
    this.vehicleTypeId,
    this.name,
    this.formFactor,
    this.propulsionType,
    this.maxRangeMeters,
  });

  factory RentalVehicleType.fromJson(Map<String, dynamic> json) =>
      RentalVehicleType(
        vehicleTypeId: json['vehicleTypeId'],
        name: json['name'],
        formFactor: json['formFactor'],
        propulsionType: json['propulsionType'],
        maxRangeMeters: json['maxRangeMeters'],
      );
}

@immutable
class RoutingError {
  final RoutingErrorCode? code;
  final InputField? inputField;
  final String? description;

  const RoutingError({this.code, this.inputField, this.description});

  factory RoutingError.fromJson(Map<String, dynamic> json) => RoutingError(
    code: RoutingErrorCode.values.fromString(json['code']),
    inputField: json['inputField'] != null
        ? InputField.values.fromString(json['inputField'])
        : null,
    description: json['description'],
  );
}

@immutable
class RoutingParameters {
  const RoutingParameters({
    this.walkSpeed,
    this.bikeSpeed,
    this.maxDirectStreetDuration,
    this.wheelChairAccessible,
    this.numItineraries,
    this.maxSlope,
    this.transferPenalty,
    this.walkReluctance,
    this.stairsReluctance,
    this.turnReluctance,
    this.elevatorBoardTime,
    this.elevatorBoardCost,
    this.elevatorHopTime,
    this.elevatorHopCost,
    this.bikeRentalPickupTime,
    this.bikeRentalPickupCost,
    this.bikeRentalDropOffTime,
    this.bikeRentalDropOffCost,
    this.bikeParkTime,
    this.bikeParkCost,
    this.carDropOffTime,
    this.waitReluctance,
    this.walkBoardCost,
    this.bikeBoardCost,
    this.otherThanPreferredRoutesPenalty,
    this.transferSlack,
    this.boardSlackDefault,
    this.boardSlackList,
    this.alightSlackDefault,
    this.alightSlackList,
    this.maxTransfers,
    this.maxAdditionalTransfers,
    this.carDecelerationSpeed,
    this.carAccelerationSpeed,
    this.ignoreRealTimeUpdates,
    this.includedPlannedCancellations,
    this.disableRemainingWeightHeuristic,
    this.geoIdElevation,
  });

  factory RoutingParameters.fromJson(
    Map<String, dynamic> json,
  ) => RoutingParameters(
    walkSpeed: json['walkSpeed'],
    bikeSpeed: json['bikeSpeed'],
    maxDirectStreetDuration: json['maxDirectStreetDuration'],
    wheelChairAccessible: json['wheelChairAccessible'],
    numItineraries: json['numItineraries'],
    maxSlope: json['maxSlope'],
    transferPenalty: json['transferPenalty'],
    walkReluctance: json['walkReluctance'],
    stairsReluctance: json['stairsReluctance'],
    turnReluctance: json['turnReluctance'],
    elevatorBoardTime: json['elevatorBoardTime'],
    elevatorBoardCost: json['elevatorBoardCost'],
    elevatorHopTime: json['elevatorHopTime'],
    elevatorHopCost: json['elevatorHopCost'],
    bikeRentalPickupTime: json['bikeRentalPickupTime'],
    bikeRentalPickupCost: json['bikeRentalPickupCost'],
    bikeRentalDropOffTime: json['bikeRentalDropOffTime'],
    bikeRentalDropOffCost: json['bikeRentalDropOffCost'],
    bikeParkTime: json['bikeParkTime'],
    bikeParkCost: json['bikeParkCost'],
    carDropOffTime: json['carDropOffTime'],
    waitReluctance: json['waitReluctance'],
    walkBoardCost: json['walkBoardCost'],
    bikeBoardCost: json['bikeBoardCost'],
    otherThanPreferredRoutesPenalty: json['otherThanPreferredRoutesPenalty'],
    transferSlack: json['transferSlack'],
    boardSlackDefault: json['boardSlackDefault'],
    boardSlackList: (json['boardSlackList'] as List?)
        ?.map((e) => TransportModeSlackType.fromJson(e))
        .toList(),
    alightSlackDefault: json['alightSlackDefault'],
    alightSlackList: (json['alightSlackList'] as List?)
        ?.map((e) => TransportModeSlackType.fromJson(e))
        .toList(),
    maxTransfers: json['maxTransfers'],
    maxAdditionalTransfers: json['maxAdditionalTransfers'],
    carDecelerationSpeed: json['carDecelerationSpeed'],
    carAccelerationSpeed: json['carAccelerationSpeed'],
    ignoreRealTimeUpdates: json['ignoreRealTimeUpdates'],
    includedPlannedCancellations: json['includedPlannedCancellations'],
    disableRemainingWeightHeuristic: json['disableRemainingWeightHeuristic'],
    geoIdElevation: json['geoIdElevation'],
  );

  final double? walkSpeed;
  final double? bikeSpeed;
  final int? maxDirectStreetDuration;
  final bool? wheelChairAccessible;
  final int? numItineraries;
  final double? maxSlope;
  final int? transferPenalty;
  final double? walkReluctance;
  final double? stairsReluctance;
  final double? turnReluctance;
  final int? elevatorBoardTime;
  final int? elevatorBoardCost;
  final int? elevatorHopTime;
  final int? elevatorHopCost;
  final int? bikeRentalPickupTime;
  final int? bikeRentalPickupCost;
  final int? bikeRentalDropOffTime;
  final int? bikeRentalDropOffCost;
  final int? bikeParkTime;
  final int? bikeParkCost;
  final int? carDropOffTime;
  final double? waitReluctance;
  final int? walkBoardCost;
  final int? bikeBoardCost;
  final int? otherThanPreferredRoutesPenalty;
  final int? transferSlack;
  final int? boardSlackDefault;
  final List<TransportModeSlackType>? boardSlackList;
  final int? alightSlackDefault;
  final List<TransportModeSlackType>? alightSlackList;
  final int? maxTransfers;
  final int? maxAdditionalTransfers;
  final double? carDecelerationSpeed;
  final double? carAccelerationSpeed;
  final bool? ignoreRealTimeUpdates;
  final bool? includedPlannedCancellations;
  final bool? disableRemainingWeightHeuristic;
  final bool? geoIdElevation;
}

@immutable
class ServerInfo {
  final String? version;
  final String? buildTime;
  final String? gitBranch;
  final String? gitCommit;
  final String? gitCommitTime;
  final String? otpConfigVersion;
  final String? buildConfigVersion;
  final String? routerConfigVersion;
  final String? otpSerializationVersionId;
  final String? internalTransitModelTimeZone;

  const ServerInfo({
    this.version,
    this.buildTime,
    this.gitBranch,
    this.gitCommit,
    this.gitCommitTime,
    this.otpConfigVersion,
    this.buildConfigVersion,
    this.routerConfigVersion,
    this.otpSerializationVersionId,
    this.internalTransitModelTimeZone,
  });

  factory ServerInfo.fromJson(Map<String, dynamic> json) => ServerInfo(
    version: json['version'],
    buildTime: json['buildTime'],
    gitBranch: json['gitBranch'],
    gitCommit: json['gitCommit'],
    gitCommitTime: json['gitCommitTime'],
    otpConfigVersion: json['otpConfigVersion'],
    buildConfigVersion: json['buildConfigVersion'],
    routerConfigVersion: json['routerConfigVersion'],
    otpSerializationVersionId: json['otpSerializationVersionId'],
    internalTransitModelTimeZone: json['internalTransitModelTimeZone'],
  );
}

@immutable
class ServiceJourney {
  const ServiceJourney({
    this.id,
    this.line,
    this.activeDates,
    this.transportMode,
    this.transportSubmode,
    this.publicCode,
    this.privateCode,
    this.operator,
    this.directionType,
    this.wheelchairAccessible,
    this.bikesAllowed,
    this.journeyPattern,
    this.quays,
    this.passingTimes,
    this.estimatedCalls,
    this.pointsOnLink,
    this.notices,
    this.situations,
  });

  factory ServiceJourney.fromJson(Map<String, dynamic> json) => ServiceJourney(
    id: json['id'],
    line: json['line'] != null ? Line.fromJson(json['line']) : null,
    activeDates: (json['activeDates'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    transportMode: TransportMode.values.fromString(json['transportMode']),
    transportSubmode: TransportSubmode.values.fromString(
      json['transportSubmode'],
    ),
    publicCode: json['publicCode'],
    privateCode: json['privateCode'],
    operator: json['operator'] != null
        ? Operator.fromJson(json['operator'])
        : null,
    directionType: DirectionType.values.fromString(json['directionType']),
    wheelchairAccessible: WheelchairBoarding.values.fromString(
      json['wheelchairAccessible'],
    ),
    bikesAllowed: BikesAllowed.values.fromString(json['bikesAllowed']),
    journeyPattern: json['journeyPattern'] != null
        ? JourneyPattern.fromJson(json['journeyPattern'])
        : null,
    quays: (json['quays'] as List?)?.map((e) => Quay.fromJson(e)).toList(),
    passingTimes: (json['passingTimes'] as List?)
        ?.map((e) => TimetabledPassingTime.fromJson(e))
        .toList(),
    estimatedCalls: (json['estimatedCalls'] as List?)
        ?.map((e) => EstimatedCall.fromJson(e))
        .toList(),
    pointsOnLink: json['pointsOnLink'] != null
        ? PointsOnLink.fromJson(json['pointsOnLink'])
        : null,
    notices: (json['notices'] as List?)
        ?.map((e) => Notice.fromJson(e))
        .toList(),
    situations: (json['situations'] as List?)
        ?.map((e) => PtSituationElement.fromJson(e))
        .toList(),
  );

  final String? id;
  final Line? line;
  final List<String>? activeDates;
  final TransportMode? transportMode;
  final TransportSubmode? transportSubmode;
  final String? publicCode;
  final String? privateCode;
  final Operator? operator;
  final DirectionType? directionType;
  final WheelchairBoarding? wheelchairAccessible;
  final BikesAllowed? bikesAllowed;
  final JourneyPattern? journeyPattern;
  final List<Quay>? quays;
  final List<TimetabledPassingTime>? passingTimes;
  final List<EstimatedCall>? estimatedCalls;
  final PointsOnLink? pointsOnLink;
  final List<Notice>? notices;
  final List<PtSituationElement>? situations;
}

@immutable
class StopPlace {
  const StopPlace({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.description,
    this.stopInterchangePriority,
    this.tariffZones,
    this.transportMode,
    this.transportSubmode,
    this.timeZone,
    this.quays,
    this.parent,
    this.situations,
  });

  factory StopPlace.fromJson(Map<String, dynamic> json) => StopPlace(
    id: json['id'],
    name: json['name'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    description: json['description'],
    stopInterchangePriority: StopInterchangePriority.values.fromString(
      json['stopInterchangePriority'],
    ),
    tariffZones: (json['tariffZones'] as List?)
        ?.map((e) => TariffZone.fromJson(e))
        .toList(),
    transportMode: (json['transportMode'] as List?)
        ?.map((e) => TransportMode.values.fromString(e))
        .toList(),
    transportSubmode: (json['transportSubmode'] as List?)
        ?.map((e) => TransportSubmode.values.fromString(e))
        .toList(),
    timeZone: json['timeZone'],
    quays: (json['quays'] as List?)?.map((e) => Quay.fromJson(e)).toList(),
    parent: json['parent'] != null ? StopPlace.fromJson(json['parent']) : null,
    situations: (json['situations'] as List?)
        ?.map((e) => PtSituationElement.fromJson(e))
        .toList(),
  );

  final String? id;
  final String? name;
  final double? latitude;
  final double? longitude;
  final String? description;
  final StopInterchangePriority? stopInterchangePriority;
  final List<TariffZone>? tariffZones;
  final List<TransportMode?>? transportMode;
  final List<TransportSubmode?>? transportSubmode;
  final String? timeZone;
  final List<Quay>? quays;
  final StopPlace? parent;
  final List<PtSituationElement>? situations;
}

@immutable
class StopToStopGeometry {
  final PointsOnLink? pointsOnLink;
  final Quay? fromQuay;
  final Quay? toQuay;

  const StopToStopGeometry({this.pointsOnLink, this.fromQuay, this.toQuay});

  factory StopToStopGeometry.fromJson(Map<String, dynamic> json) =>
      StopToStopGeometry(
        pointsOnLink: json['pointsOnLink'] != null
            ? PointsOnLink.fromJson(json['pointsOnLink'])
            : null,
        fromQuay: json['fromQuay'] != null
            ? Quay.fromJson(json['fromQuay'])
            : null,
        toQuay: json['toQuay'] != null ? Quay.fromJson(json['toQuay']) : null,
      );
}

@immutable
class StreetModeDurationInput {
  final StreetMode? streetMode;
  final String? duration;

  const StreetModeDurationInput({this.streetMode, this.duration});

  factory StreetModeDurationInput.fromJson(Map<String, dynamic> json) =>
      StreetModeDurationInput(
        streetMode: StreetMode.values.fromString(json['streetMode']),
        duration: json['duration'],
      );
}

@immutable
class StreetModes {
  final StreetMode? accessMode;
  final StreetMode? egressMode;
  final StreetMode? directMode;

  const StreetModes({this.accessMode, this.egressMode, this.directMode});

  factory StreetModes.fromJson(Map<String, dynamic> json) => StreetModes(
    accessMode: StreetMode.values.fromString(json['accessMode']),
    egressMode: StreetMode.values.fromString(json['egressMode']),
    directMode: StreetMode.values.fromString(json['directMode']),
  );
}

@immutable
class SystemNotice {
  final String? tag;
  final String? text;

  const SystemNotice({this.tag, this.text});

  factory SystemNotice.fromJson(Map<String, dynamic> json) =>
      SystemNotice(tag: json['tag'], text: json['text']);
}

@immutable
class TariffZone {
  final String? id;
  final String? name;

  const TariffZone({this.id, this.name});

  factory TariffZone.fromJson(Map<String, dynamic> json) =>
      TariffZone(id: json['id'], name: json['name']);
}

@immutable
class TimeAndDayOffset {
  final String? time;
  final int? dayOffset;

  const TimeAndDayOffset({this.time, this.dayOffset});

  factory TimeAndDayOffset.fromJson(Map<String, dynamic> json) =>
      TimeAndDayOffset(time: json['time'], dayOffset: json['dayOffset']);
}

@immutable
class TimePenaltyWithCost {
  final String? appliedTo;
  final String? timePenalty;
  final int? generalizedCostDelta;

  const TimePenaltyWithCost({
    this.appliedTo,
    this.timePenalty,
    this.generalizedCostDelta,
  });

  factory TimePenaltyWithCost.fromJson(Map<String, dynamic> json) =>
      TimePenaltyWithCost(
        appliedTo: json['appliedTo'],
        timePenalty: json['timePenalty'],
        generalizedCostDelta: json['generalizedCostDelta'],
      );
}

@immutable
class TimetabledPassingTime {
  const TimetabledPassingTime({
    this.quay,
    this.arrival,
    this.departure,
    this.timingPoint,
    this.forBoarding,
    this.forAlighting,
    this.requestStop,
    this.earliestDepartureTime,
    this.latestArrivalTime,
    this.serviceJourney,
    this.destinationDisplay,
    this.notices,
    this.bookingArrangements,
  });

  factory TimetabledPassingTime.fromJson(Map<String, dynamic> json) =>
      TimetabledPassingTime(
        quay: json['quay'] != null ? Quay.fromJson(json['quay']) : null,
        arrival: json['arrival'] != null
            ? TimeAndDayOffset.fromJson(json['arrival'])
            : null,
        departure: json['departure'] != null
            ? TimeAndDayOffset.fromJson(json['departure'])
            : null,
        timingPoint: json['timingPoint'],
        forBoarding: json['forBoarding'],
        forAlighting: json['forAlighting'],
        requestStop: json['requestStop'],
        earliestDepartureTime: json['earliestDepartureTime'] != null
            ? TimeAndDayOffset.fromJson(json['earliestDepartureTime'])
            : null,
        latestArrivalTime: json['latestArrivalTime'] != null
            ? TimeAndDayOffset.fromJson(json['latestArrivalTime'])
            : null,
        serviceJourney: json['serviceJourney'] != null
            ? ServiceJourney.fromJson(json['serviceJourney'])
            : null,
        destinationDisplay: json['destinationDisplay'] != null
            ? DestinationDisplay.fromJson(json['destinationDisplay'])
            : null,
        notices: (json['notices'] as List?)
            ?.map((e) => Notice.fromJson(e))
            .toList(),
        bookingArrangements: json['bookingArrangements'] != null
            ? BookingArrangement.fromJson(json['bookingArrangements'])
            : null,
      );

  final Quay? quay;
  final TimeAndDayOffset? arrival;
  final TimeAndDayOffset? departure;
  final bool? timingPoint;
  final bool? forBoarding;
  final bool? forAlighting;
  final bool? requestStop;
  final TimeAndDayOffset? earliestDepartureTime;
  final TimeAndDayOffset? latestArrivalTime;
  final ServiceJourney? serviceJourney;
  final DestinationDisplay? destinationDisplay;
  final List<Notice>? notices;
  final BookingArrangement? bookingArrangements;
}

@immutable
class TransitGeneralizedCostFilterParams {
  // final DoubleFunction? costLimitFunction;
  final double? intervalRelaxFactor;

  const TransitGeneralizedCostFilterParams({
    // this.costLimitFunction,
    this.intervalRelaxFactor,
  });

  factory TransitGeneralizedCostFilterParams.fromJson(
    Map<String, dynamic> json,
  ) => TransitGeneralizedCostFilterParams(
    // costLimitFunction: json['costLimitFunction'] != null ? DoubleFunction.fromJson(json['costLimitFunction']) : null,
    intervalRelaxFactor: json['intervalRelaxFactor'],
  );
}

@immutable
class TransportModes {
  final TransportMode? transportMode;
  final List<TransportSubmode?>? transportSubModes;
  const TransportModes({this.transportMode, this.transportSubModes});

  factory TransportModes.fromJson(Map<String, dynamic> json) => TransportModes(
    transportMode: TransportMode.values.fromString(json['transportMode']),
    transportSubModes: (json['transportSubModes'] as List?)
        ?.map((e) => TransportSubmode.values.fromString(e))
        .toList(),
  );
}

@immutable
class TransportModeSlack {
  final int? slack;
  final List<TransportMode?>? modes;
  const TransportModeSlack({this.slack, this.modes});

  factory TransportModeSlack.fromJson(Map<String, dynamic> json) =>
      TransportModeSlack(
        slack: json['slack'],
        modes: (json['modes'] as List?)
            ?.map((e) => TransportMode.values.fromString(e))
            .toList(),
      );
}

@immutable
class TransportModeSlackType {
  final int? slack;
  final List<TransportMode?>? modes;
  const TransportModeSlackType({this.slack, this.modes});

  factory TransportModeSlackType.fromJson(Map<String, dynamic> json) =>
      TransportModeSlackType(
        slack: json['slack'],
        modes: (json['modes'] as List?)
            ?.map((e) => TransportMode.values.fromString(e))
            .toList(),
      );
}

@immutable
class TriangleFactors {
  final double? safety;
  final double? slope;
  final double? time;

  const TriangleFactors({this.safety, this.slope, this.time});

  factory TriangleFactors.fromJson(Map<String, dynamic> json) =>
      TriangleFactors(
        safety: json['safety'],
        slope: json['slope'],
        time: json['time'],
      );
}

@immutable
class DebugOutput {
  final int? totalTime;

  const DebugOutput({this.totalTime});

  factory DebugOutput.fromJson(Map<String, dynamic> json) =>
      DebugOutput(totalTime: json['totalTime']);
}

@immutable
class Trip {
  final String? dateTime;
  final TripSearchData? metadata;
  final Place? fromPlace;
  final Place? toPlace;
  final List<TripPattern>? tripPatterns;
  final List<RoutingError>? routingErrors;
  final DebugOutput? debugOutput;
  final String? previousPageCursor;
  final String? nextPageCursor;
  const Trip({
    this.dateTime,
    this.metadata,
    this.fromPlace,
    this.toPlace,
    this.tripPatterns,
    this.routingErrors,
    this.debugOutput,
    this.previousPageCursor,
    this.nextPageCursor,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    dateTime: json['dateTime'],
    metadata: json['metadata'] != null
        ? TripSearchData.fromJson(json['metadata'])
        : null,
    fromPlace: json['fromPlace'] != null
        ? Place.fromJson(json['fromPlace'])
        : null,
    toPlace: json['toPlace'] != null ? Place.fromJson(json['toPlace']) : null,
    tripPatterns: (json['tripPatterns'] as List?)
        ?.map((e) => TripPattern.fromJson(e))
        .toList(),
    routingErrors: (json['routingErrors'] as List?)
        ?.map((e) => RoutingError.fromJson(e))
        .toList(),
    debugOutput: json['debugOutput'] != null
        ? DebugOutput.fromJson(json['debugOutput'])
        : null,
    previousPageCursor: json['previousPageCursor'],
    nextPageCursor: json['nextPageCursor'],
  );

  PlanEntity toUIModel() {
    return PlanEntity(
      from: fromPlace?.toPlanLocation(),
      to: toPlace?.toPlanLocation(),
      itineraries: tripPatterns
          ?.map((itinerary) => itinerary.toPlanItinerary())
          .toList(),
    );
  }
}

@immutable
class TripFilterInput {
  const TripFilterInput({this.select, this.not});

  factory TripFilterInput.fromJson(Map<String, dynamic> json) =>
      TripFilterInput(
        select: (json['select'] as List?)
            ?.map((e) => TripFilterSelectInput.fromJson(e))
            .toList(),
        not: (json['not'] as List?)
            ?.map((e) => TripFilterSelectInput.fromJson(e))
            .toList(),
      );

  final List<TripFilterSelectInput>? select;
  final List<TripFilterSelectInput>? not;
}

@immutable
class TripFilterSelectInput {
  final List<String>? lines;
  final List<String>? authorities;
  final List<String>? serviceJourneys;
  final List<TransportModes>? transportModes;
  final List<String>? groupOfLines;
  const TripFilterSelectInput({
    this.lines,
    this.authorities,
    this.serviceJourneys,
    this.transportModes,
    this.groupOfLines,
  });

  factory TripFilterSelectInput.fromJson(Map<String, dynamic> json) =>
      TripFilterSelectInput(
        lines: (json['lines'] as List?)?.map((e) => e.toString()).toList(),
        authorities: (json['authorities'] as List?)
            ?.map((e) => e.toString())
            .toList(),
        serviceJourneys: (json['serviceJourneys'] as List?)
            ?.map((e) => e.toString())
            .toList(),
        transportModes: (json['transportModes'] as List?)
            ?.map((e) => TransportModes.fromJson(e))
            .toList(),
        groupOfLines: (json['groupOfLines'] as List?)
            ?.map((e) => e.toString())
            .toList(),
      );
}

@immutable
class TripPassThroughViaLocationInput {
  final String? label;
  final List<String>? stopLocationIds;
  const TripPassThroughViaLocationInput({this.label, this.stopLocationIds});

  factory TripPassThroughViaLocationInput.fromJson(Map<String, dynamic> json) =>
      TripPassThroughViaLocationInput(
        label: json['label'],
        stopLocationIds: (json['stopLocationIds'] as List?)
            ?.map((e) => e.toString())
            .toList(),
      );
}

@immutable
class TripPattern {
  final String? aimedStartTime;
  final String? expectedStartTime;
  final String? aimedEndTime;
  final String? expectedEndTime;
  final int? duration;
  final int? directDuration;
  final int? waitingTime;
  final double? distance;
  final int? walkTime;
  final double? streetDistance;
  final List<Leg>? legs;
  final List<SystemNotice>? systemNotices;
  final int? generalizedCost;
  final int? generalizedCost2;
  final int? waitTimeOptimizedCost;
  final int? transferPriorityCost;
  final List<TimePenaltyWithCost>? timePenalty;
  const TripPattern({
    this.aimedStartTime,
    this.expectedStartTime,
    this.aimedEndTime,
    this.expectedEndTime,
    this.duration,
    this.directDuration,
    this.waitingTime,
    this.distance,
    this.walkTime,
    this.streetDistance,
    this.legs,
    this.systemNotices,
    this.generalizedCost,
    this.generalizedCost2,
    this.waitTimeOptimizedCost,
    this.transferPriorityCost,
    this.timePenalty,
  });

  factory TripPattern.fromJson(Map<String, dynamic> json) => TripPattern(
    aimedStartTime: json['aimedStartTime'],
    expectedStartTime: json['expectedStartTime'],
    aimedEndTime: json['aimedEndTime'],
    expectedEndTime: json['expectedEndTime'],
    duration: json['duration'],
    directDuration: json['directDuration'],
    waitingTime: json['waitingTime'],
    distance: json['distance'],
    walkTime: json['walkTime'],
    streetDistance: json['streetDistance'],
    legs: (json['legs'] as List?)?.map((e) => Leg.fromJson(e)).toList(),
    systemNotices: (json['systemNotices'] as List?)
        ?.map((e) => SystemNotice.fromJson(e))
        .toList(),
    generalizedCost: json['generalizedCost'],
    generalizedCost2: json['generalizedCost2'],
    waitTimeOptimizedCost: json['waitTimeOptimizedCost'],
    transferPriorityCost: json['transferPriorityCost'],
    timePenalty: (json['timePenalty'] as List?)
        ?.map((e) => TimePenaltyWithCost.fromJson(e))
        .toList(),
  );

  PlanItinerary toPlanItinerary() {
    return PlanItinerary(
      legs: legs?.map((leg) => leg.toPlanItineraryLeg()).toList() ?? [],
      startTime: DateTime.parse(expectedStartTime!),
      endTime: DateTime.parse(expectedEndTime!),
      duration: Duration(seconds: duration ?? 0),
      walkDistance: streetDistance ?? 0,
      walkTime: Duration(seconds: walkTime ?? 0),
      // TODO review this value for stadtnavi funcionality
      arrivedAtDestinationWithRentedBicycle: false,
      emissionsPerPerson: null,
    );
  }
}

@immutable
class TripSearchData {
  final int? searchWindowUsed;

  const TripSearchData({this.searchWindowUsed});

  factory TripSearchData.fromJson(Map<String, dynamic> json) =>
      TripSearchData(searchWindowUsed: json['searchWindowUsed']);
}

@immutable
class TripViaLocationInput {
  final TripVisitViaLocationInput? visit;
  final TripPassThroughViaLocationInput? passThrough;

  const TripViaLocationInput({this.visit, this.passThrough});

  factory TripViaLocationInput.fromJson(Map<String, dynamic> json) =>
      TripViaLocationInput(
        visit: json['visit'] != null
            ? TripVisitViaLocationInput.fromJson(json['visit'])
            : null,
        passThrough: json['passThrough'] != null
            ? TripPassThroughViaLocationInput.fromJson(json['passThrough'])
            : null,
      );
}

@immutable
class TripVisitViaLocationInput {
  final String? label;
  final String? minimumWaitTime;
  final List<String>? stopLocationIds;
  final InputCoordinates? coordinate;
  const TripVisitViaLocationInput({
    this.label,
    this.minimumWaitTime,
    this.stopLocationIds,
    this.coordinate,
  });

  factory TripVisitViaLocationInput.fromJson(Map<String, dynamic> json) =>
      TripVisitViaLocationInput(
        label: json['label'],
        minimumWaitTime: json['minimumWaitTime'],
        stopLocationIds: (json['stopLocationIds'] as List?)
            ?.map((e) => e.toString())
            .toList(),
        coordinate: json['coordinate'] != null
            ? InputCoordinates.fromJson(json['coordinate'])
            : null,
      );
}

@immutable
class ValidityPeriod {
  final String? startTime;
  final String? endTime;

  const ValidityPeriod({this.startTime, this.endTime});

  factory ValidityPeriod.fromJson(Map<String, dynamic> json) =>
      ValidityPeriod(startTime: json['startTime'], endTime: json['endTime']);
}

@immutable
class ViaConnection {
  final int? from;
  final int? to;

  const ViaConnection({this.from, this.to});

  factory ViaConnection.fromJson(Map<String, dynamic> json) =>
      ViaConnection(from: json['from'], to: json['to']);
}

@immutable
class ViaLocationInput {
  final String? name;
  final String? place;
  final InputCoordinates? coordinates;
  final String? minSlack;
  final String? maxSlack;

  const ViaLocationInput({
    this.name,
    this.place,
    this.coordinates,
    this.minSlack,
    this.maxSlack,
  });

  factory ViaLocationInput.fromJson(Map<String, dynamic> json) =>
      ViaLocationInput(
        name: json['name'],
        place: json['place'],
        coordinates: json['coordinates'] != null
            ? InputCoordinates.fromJson(json['coordinates'])
            : null,
        minSlack: json['minSlack'],
        maxSlack: json['maxSlack'],
      );
}

@immutable
class ViaSegmentInput {
  final StreetModes? modes;
  final List<TripFilterInput>? filters;
  const ViaSegmentInput({this.modes, this.filters});

  factory ViaSegmentInput.fromJson(Map<String, dynamic> json) =>
      ViaSegmentInput(
        modes: json['modes'] != null
            ? StreetModes.fromJson(json['modes'])
            : null,
        filters: (json['filters'] as List?)
            ?.map((e) => TripFilterInput.fromJson(e))
            .toList(),
      );
}

@immutable
class ViaTrip {
  final List<ViaTripPatternSegment>? tripPatternsPerSegment;
  final List<ViaConnection>? tripPatternCombinations;
  final List<RoutingError>? routingErrors;
  const ViaTrip({
    this.tripPatternsPerSegment,
    this.tripPatternCombinations,
    this.routingErrors,
  });

  factory ViaTrip.fromJson(Map<String, dynamic> json) => ViaTrip(
    tripPatternsPerSegment: (json['tripPatternsPerSegment'] as List?)
        ?.map((e) => ViaTripPatternSegment.fromJson(e))
        .toList(),
    tripPatternCombinations: (json['tripPatternCombinations'] as List?)
        ?.map((e) => ViaConnection.fromJson(e))
        .toList(),
    routingErrors: (json['routingErrors'] as List?)
        ?.map((e) => RoutingError.fromJson(e))
        .toList(),
  );
}

@immutable
class ViaTripPatternSegment {
  final List<TripPattern>? tripPatterns;
  const ViaTripPatternSegment({this.tripPatterns});

  factory ViaTripPatternSegment.fromJson(Map<String, dynamic> json) =>
      ViaTripPatternSegment(
        tripPatterns: (json['tripPatterns'] as List?)
            ?.map((e) => TripPattern.fromJson(e))
            .toList(),
      );
}

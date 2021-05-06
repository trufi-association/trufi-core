import 'package:meta/meta.dart';

import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/plan/setting_panel/setting_panel_cubit.dart';

String getPlanComplete({
  @required double fromLat,
  @required double fromLon,
  @required double toLat,
  @required double toLon,
}) {
  return '''
  plan(
    from: {lat: $fromLat, lon:  $fromLon}
    to: {lat: $toLat, lon:  $toLon}
    transportModes: [{mode:WALK},{mode:TRANSIT}]
    numItineraries: 5
  ) {
    date,
    from{
      name,
      lon,
      lat,
      vertexType
    },
    to{
      name,
      lon,
      lat,
      vertexType,
    },
    itineraries {
      duration,
      startTime,
      endTime,
      walkTime,
      waitingTime,
      walkDistance,
      elevationLost,
      elevationGained,
      legs{
        startTime,
        endTime,
        departureDelay,
        arrivalDelay,
        realTime,
        distance,
        mode,
        agency{
          name,
        },
        route{
          url
          shortName
          longName
        },
        interlineWithPreviousLeg,
        from{
      		name,
      		lon,
      		lat,
      		vertexType,
      		departureTime,
        },
        to{
      		name,
      		lon,
      		lat,
      		vertexType,
      		departureTime,
        },
        legGeometry{
        	points,
          length
        },
        rentedBike,
        transitLeg,
        duration,
        steps{
          distance,
          lon,
          lat,
          elevationProfile{
            distance,
            elevation
          }
        },
      },
    }
  }
''';
}

String getCustomPlan({
  @required double fromLat,
  @required double fromLon,
  @required double toLat,
  @required double toLon,
  List<TransportMode> transportModes = const [TransportMode.transit, TransportMode.walk],
}) {
  final transportMode = _parseTransportModes(transportModes);
  return '''
    plan(
      from: {lat: $fromLat, lon:  $fromLon}
      to: {lat: $toLat, lon:  $toLon}
      transportModes: $transportMode
      numItineraries: 5
    ) {
      from{
        name,
        lat,
        lon,
      },
      to{
        name,
        lon,
        lat,
      },
      itineraries {
        legs{
          duration
          distance,
          mode,
          agency{
            name
          }
          route{
            url
            shortName
            longName
          },
          from{
        		name,
        		lon,
        		lat,
          },
          to{
        		name,
        		lon,
        		lat,
          },
          legGeometry{
          	points,
            length
          },
        },
      }
    }
''';
}

String getPlanAdvanced({
  @required double fromLat,
  @required double fromLon,
  @required double toLat,
  @required double toLon,
  // Research about use
  double bikeSpeed,
  bool avoidWalking,
  bool arriveBy = false,
  double itineraryFiltering = 1.5,
  double maxWalkDistance = 15000,
  int minTransferTime = 120,
  int transferPenalty = 0,
  String date,
  bool wheelchair = false,
  String time,
  String locale = "en",
  OptimizeType optimize = OptimizeType.quick,
  List<TransportMode> transportModes = const [TransportMode.transit, TransportMode.walk],
  List<BikeRentalNetwork> bikeRentalNetworks = const [
    BikeRentalNetwork.regioRad,
    BikeRentalNetwork.taxi,
    BikeRentalNetwork.carSharing,
  ],
  WalkBoardCost walkBoardCost = WalkBoardCost.defaultCost,
  WalkingSpeed walkingSpeed = WalkingSpeed.fast,
}) {
  final dataTransportModes = _parseTransportModes(transportModes);
  final dataBikeRentalNetwork = _parseBikeRentalNetworks(bikeRentalNetworks);
  bikeSpeed ??= BikingSpeed.average.value;
  date ??= _todayMonthDayYear();
  // ignore: parameter_assignments
  final bool disableRemainingWeightHeuristic =
      transportModes.map((e) => e.name).contains("BICYCLE_RENT");
  final double walkReluctance = avoidWalking ? 5 : 2;

  final triangleOption = optimize == OptimizeType.triangle
      ? "triangle: {safetyFactor: 0.4, slopeFactor: 0.3, timeFactor: 0.3}"
      : '';
  return '''
    plan(
      allowedBikeRentalNetworks:$dataBikeRentalNetwork
      arriveBy: $arriveBy
      bikeSpeed: $bikeSpeed
      date: $date
      disableRemainingWeightHeuristic: $disableRemainingWeightHeuristic
      from: {lat: $fromLat, lon:  $fromLon}
      intermediatePlaces: []
      itineraryFiltering: $itineraryFiltering
      locale: "$locale"
      maxWalkDistance: $maxWalkDistance
      minTransferTime: $minTransferTime
      transportModes: $dataTransportModes
      numItineraries: 5
      optimize: ${optimize.name}
      $triangleOption
      to: {lat: $toLat, lon:  $toLon}
      transferPenalty: $transferPenalty
      unpreferred: {useUnpreferredRoutesPenalty: 1200}
      walkBoardCost: ${walkBoardCost.value}
      walkReluctance: $walkReluctance
      walkSpeed: ${walkingSpeed.value}
      wheelchair: $wheelchair
    ) {
      from{
        name,
        lat,
        lon,
      },
      to{
        name,
        lon,
        lat,
      },
      itineraries {
        legs{
          duration
          distance,
          mode,
          agency{
            name
          }
          route{
            url
            shortName
            longName
          },
          from{
        		name,
        		lon,
        		lat,
          },
          to{
        		name,
        		lon,
        		lat,
          },
          legGeometry{
          	points,
            length
          },
        },
      }
    }
''';
}

String _parseTransportModes(List<TransportMode> list) {
  final dataParse = list.map((e) => '{mode:${e.name}}').join(',');
  return '[$dataParse]';
}

String _parseBikeRentalNetworks(List<BikeRentalNetwork> list) {
  final dataParse = list.map((e) => '"${e.name}"').join(',');
  return '[$dataParse]';
}

String _todayMonthDayYear() {
  final today = DateTime.now();
  final dataDate = today.year.toString() +
      "-${today.month.toString().padLeft(2, '0')}" +
      "-${today.day.toString().padLeft(2, '0')}";
  return '"$dataDate"';
}

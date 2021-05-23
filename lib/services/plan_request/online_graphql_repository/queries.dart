import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

// String getPlanComplete({
//   @required double fromLat,
//   @required double fromLon,
//   @required double toLat,
//   @required double toLon,
// }) {
//   return '''
//   plan(
//     from: {lat: $fromLat, lon:  $fromLon}
//     to: {lat: $toLat, lon:  $toLon}
//     transportModes: [{mode:WALK},{mode:TRANSIT}]
//     numItineraries: 5
//   ) {
//     date,
//     from{
//       name,
//       lon,
//       lat,
//       vertexType
//     },
//     to{
//       name,
//       lon,
//       lat,
//       vertexType,
//     },
//     itineraries {
//       duration,
//       startTime,
//       endTime,
//       walkTime,
//       waitingTime,
//       walkDistance,
//       elevationLost,
//       elevationGained,
//       legs{
//         startTime,
//         endTime,
//         departureDelay,
//         arrivalDelay,
//         realTime,
//         distance,
//         mode,
//         agency{
//           name,
//         },
//         route{
//           url
//           shortName
//           longName
//         },
//         interlineWithPreviousLeg,
//         from{
//       		name,
//       		lon,
//       		lat,
//       		vertexType,
//       		departureTime,
//         },
//         to{
//       		name,
//       		lon,
//       		lat,
//       		vertexType,
//       		departureTime,
//         },
//         legGeometry{
//         	points,
//           length
//         },
//         rentedBike,
//         transitLeg,
//         duration,
//         steps{
//           distance,
//           lon,
//           lat,
//           elevationProfile{
//             distance,
//             elevation
//           }
//         },
//       },
//     }
//   }
// ''';
// }

String getCustomPlan({
  @required double fromLat,
  @required double fromLon,
  @required double toLat,
  @required double toLon,
  List<TransportMode> transportModes = const [
    TransportMode.transit,
    TransportMode.walk
  ],
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
  bool avoidWalking = false,
  bool arriveBy = false,
  bool wheelchair = false,
  double itineraryFiltering = 1.5,
  double maxWalkDistance = 15000,
  int minTransferTime = 120,
  int transferPenalty = 0,
  String locale = "en",
  List<TransportMode> transportModes = const [
    TransportMode.transit,
    TransportMode.walk
  ],
  List<BikeRentalNetwork> bikeRentalNetworks = const [
    BikeRentalNetwork.regioRad,
    BikeRentalNetwork.taxi,
    BikeRentalNetwork.carSharing,
  ],
  OptimizeType optimize = OptimizeType.quick,
  WalkBoardCost walkBoardCost = WalkBoardCost.defaultCost,
  WalkingSpeed walkingSpeed = WalkingSpeed.fast,
  BikingSpeed bikeSpeed = BikingSpeed.average,
  DateTime date,
}) {
  final dataTransportModes = _parseTransportModes(transportModes);
  final dataBikeRentalNetwork = _parseBikeRentalNetworks(bikeRentalNetworks);
  final bool disableRemainingWeightHeuristic =
      transportModes.map((e) => e.name).contains("BICYCLE");
  final double walkReluctance = avoidWalking ? 5 : 2;
  final triangleOption = optimize == OptimizeType.triangle
      ? "triangle: {safetyFactor: 0.4, slopeFactor: 0.3, timeFactor: 0.3}"
      : '';
  final dateValue = _parseDate(date);
  final timeValue = _parseTime(date);
  return '''
    plan(
      allowedBikeRentalNetworks: $dataBikeRentalNetwork
      arriveBy: $arriveBy
      bikeSpeed: ${bikeSpeed.value}
      date: $dateValue
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
      time: $timeValue
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
  final dataParse = list
      .map((e) => '{mode:${e.name}${_parseQualifier(e.qualifier)}}')
      .join(',');
  return '[$dataParse]';
}

String _parseQualifier(String qualifier) {
  String tempAualifier = qualifier;
  if (tempAualifier != "") {
    tempAualifier = ', qualifier:$tempAualifier';
  }
  return tempAualifier;
}

String _parseBikeRentalNetworks(List<BikeRentalNetwork> list) {
  final dataParse = list.map((e) => '"${e.name}"').join(',');
  return '[$dataParse]';
}

String _parseDate(DateTime date) {
  final tempDate = date ?? DateTime.now();
  return '"${DateFormat('yyyy-MM-dd').format(tempDate)}"';
}

String _parseTime(DateTime date) {
  final tempDate = date ?? DateTime.now();
  return '"${DateFormat('HH:mm:ss').format(tempDate)}"';
}

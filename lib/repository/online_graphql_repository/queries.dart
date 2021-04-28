import 'package:meta/meta.dart';

String getPlan({
  @required double fromLat,
  @required double fromLon,
  @required double toLat,
  @required double toLon,
}) {
  return '''
  plan(
    from: {lat: $fromLat, lon:  $fromLon}
    to: {lat: $toLat, lon:  $toLon}
    numItineraries: 3
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
        route{
          url
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
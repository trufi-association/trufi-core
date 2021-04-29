import 'package:meta/meta.dart';

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
        agency{
          name,
        },
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

String getPlanSimple({
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
      numItineraries: 3
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

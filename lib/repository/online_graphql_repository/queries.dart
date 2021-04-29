import 'package:meta/meta.dart';
import 'package:trufi_core/repository/online_graphql_repository/plan_graphql_model.dart';

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

String _parseTransportModes(List<TransportMode> transportModes) {
  final modes = transportModes.map((e) => '{mode:${e.name}}').join(',');
  return '[$modes]';
}

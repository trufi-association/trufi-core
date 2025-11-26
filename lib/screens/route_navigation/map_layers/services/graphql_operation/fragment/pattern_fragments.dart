import 'package:graphql/client.dart';

// Query generate TimeTable
final timetableContainerStop = gql(
  r'''
fragment RouteStopListContainer_pattern_1WWfn2 on Pattern {
  directionId
  route {
    mode
    color
    shortName
    id
  }
  stops {
    alerts {
      alertSeverityLevel
      effectiveEndDate
      effectiveStartDate
      id
    }
    stopTimesForPattern(id: $patternId, startTime: $currentTime) {
      realtime
      realtimeState
      realtimeArrival
      realtimeDeparture
      serviceDay
      scheduledDeparture
      pickupType
      stop {
        platformCode
        id
      }
    }
    gtfsId
    lat
    lon
    name
    desc
    code
    platformCode
    zoneId
    id
  }
}
  ''',
);

final routeLinePattern = gql('''
fragment RouteLine_pattern on Pattern {
  code
  geometry {
    lat
    lon
  }
  route {
    mode
    color
    id
  }
  stops {
    lat
    lon
    name
    gtfsId
    platformCode
    code
    ...StopCardHeaderContainer_stop
    id
  }
}
 ''');
final routePageMapPattern = gql('''
fragment RoutePageMap_pattern on Pattern {
  code
  directionId
  headsign
  geometry {
    lat
    lon
  }
  stops {
    lat
    lon
    name
    gtfsId
    ...StopCardHeaderContainer_stop
    id
  }
  activeDates: trips {
    day: activeDates
    id
  }
  ...RouteLine_pattern
}
''');

final stopCardHeaderContainerStop = gql(
  '''
  fragment StopCardHeaderContainer_stop on Stop {
  gtfsId
  name
  code
  desc
  zoneId
  alerts {
    alertSeverityLevel
    effectiveEndDate
    effectiveStartDate
    id
  }
  lat
  lon
  stops {
    name
    desc
    id
  }
}
''',
);

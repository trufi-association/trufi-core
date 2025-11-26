const String stopDataQuery = r'''
  query stopRoutes_StopPageHeaderContainer_Query($stopId: String!, $startTime: Long!, $timeRange: Int!, $numberOfDepartures: Int!) {
        stop(id: $stopId) {
          ...StopCardHeaderContainer_stop
          ...StopPageTabContainer_stop
          stoptimesWithoutPatterns(startTime: $startTime, timeRange: $timeRange, numberOfDepartures: $numberOfDepartures, omitCanceled: false) {
            ...DepartureListContainer_stoptimes
          }
        }
      }
''';
const String timeTableQuery = r'''
  query stopRoutes_StopPageHeaderContainer_Query($stopId: String!, $date: String!) {
        stop(id: $stopId) {
          ...TimetableContainer_stop_19b1FI
        }
      }
''';
const String citybikeQuery = r'''
  query routes_BikeRentalStation_Query(
    $id: String!
  ) {
    bikeRentalStation(id: $id) {
      ...BikeRentalStationContent_bikeRentalStation
      id
    }
  }
''';

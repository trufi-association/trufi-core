const stopAlertsQuery = r'''
  query stopRoutes_StopAlertsContainer_Query
  ($stopId: String!) {
    stop(id: $stopId) {
      ...StopAlertsContainer_stop
    }
  }
''';
const routeAlertsQuery = r'''
  query routeRoutes_RoutePage_Query(
    $routeId: String!
    $patternId: String!
  ) {
    route(id: $routeId) {
     ...RouteAlertsContainer_route
     id
    }
    pattern(id: $patternId) {
      ...RouteAlertsContainer_pattern_19b1FI
      id
    }
  }
''';

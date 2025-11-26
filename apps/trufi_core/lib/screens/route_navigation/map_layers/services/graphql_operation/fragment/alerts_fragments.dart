import 'package:graphql/client.dart';

// Query generate basicData
final stopAlertsContainer = gql(
  '''
    fragment StopAlertsContainer_stop on Stop {
      routes {
        gtfsId
      }
      gtfsId
      locationType
      alerts(types: [STOP, ROUTES]) {
        id
        alertDescriptionText
        alertHash
        alertHeaderText
        alertSeverityLevel
        alertUrl
        effectiveEndDate
        effectiveStartDate
      }
    }
  ''',
);

// Query generate basicData
final routeAlertsContainer = gql(
  '''
  fragment RouteAlertsContainer_route on Route {
    color
    mode
    type
    shortName
    gtfsId
  }
  ''',
);
final routePatternAlertsContainer = gql(
  '''
  fragment RouteAlertsContainer_pattern_19b1FI on Pattern {
    alerts(types: [ROUTE, STOPS_ON_PATTERN]) {
      id
      alertDescriptionText
      alertHash
      alertHeaderText
      alertSeverityLevel
      alertUrl
      effectiveEndDate
      effectiveStartDate
      alertDescriptionTextTranslations {
        language
        text
      }
      entities {
        __typename
        ... on Route {
          color
          type
          mode
          shortName
          gtfsId
        }
        ... on Stop {
          name
          code
          vehicleMode
          gtfsId
        }
        ... on Node {
          __isNode: __typename
          id
        }
      }
    }
  }
  ''',
);

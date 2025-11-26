import 'package:graphql/client.dart';

// Query generate basicData
final fragmentStopCardHeaderContainerstop = gql(
  '''
      fragment StopCardHeaderContainer_stop on Stop {
        id
        gtfsId
        name
        code
        desc
        zoneId
        lat
        lon
        platformCode
        vehicleMode
      }
  ''',
);
// Query generate stoptime
final stopPageTabContainerStop = gql(
  '''
fragment StopPageTabContainer_stop on Stop {
  stops {
    id
    gtfsId
    alerts {
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
      alertHeaderTextTranslations {
        language
        text
      }
      alertUrlTranslations {
        language
        text
      }
    }
  }
  alerts {
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
    alertHeaderTextTranslations {
      language
      text
    }
    alertUrlTranslations {
      language
      text
    }
  }
  routes {
    gtfsId
    shortName
    longName
    mode
    color
    alerts {
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
      alertHeaderTextTranslations {
        language
        text
      }
      alertUrlTranslations {
        language
        text
      }
      trip {
        pattern {
          code
          id
        }
        id
      }
    }
    patterns {
      code
      id
    }
    id
  }
}
  ''',
);

final departureListContainerStoptimes = gql(
  '''
  fragment DepartureListContainer_stoptimes on Stoptime {
  realtimeState
  realtimeDeparture
  scheduledDeparture
  realtimeArrival
  scheduledArrival
  realtime
  serviceDay
  pickupType
  headsign
  stop {
    id
    code
    platformCode
  }
  trip {
    id
    gtfsId
    directionId
    tripHeadsign
    stops {
      id
    }
    pattern {
      code
      id
      route {
        id
        gtfsId
        shortName
        longName
        mode
        color
        agency {
          name
          id
        }
        alerts {
          id
          alertDescriptionText
          alertHash
          alertHeaderText
          alertSeverityLevel
          alertUrl
          effectiveEndDate
          effectiveStartDate
          trip {
            pattern {
              code
              id
            }
            id
          }
          id
        }
        id
      }
      code
      stops {
        gtfsId
        code
        id
      }
      id
    }
    route {
      gtfsId
      shortName
      longName
      mode
      color
      alerts {
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
        alertHeaderTextTranslations {
          language
          text
        }
        alertUrlTranslations {
          language
          text
        }
        trip {
          pattern {
            code
            id
          }
          id
        }
      }
      id
    }
    id
  }
}
  ''',
);

// Query generate TimeTable
final timetableContainerStop = gql(
  r'''
    fragment TimetableContainer_stop_19b1FI on Stop {
      url
      locationType
      stoptimesForServiceDate(date: $date, omitCanceled: false) {
        pattern {
          headsign
          code
          route {
            id
            shortName
            longName
            mode
            agency {
              id
              name
            }
          }
          id
        }
        stoptimes {
          realtimeState
          scheduledDeparture
          serviceDay
          headsign
          pickupType
        }
      }
    }
  ''',
);

final bikeRentalStationFragment = gql(
  '''
    fragment BikeRentalStationContent_bikeRentalStation on BikeRentalStation {
      lat
      lon
      name
      spacesAvailable
      bikesAvailable
      capacity
      networks
      stationId
      state
      rentalUris {
        web
      }
    }
  ''',
);

import 'package:graphql/client.dart';

final itineraryLineLegsFragment = gql(
  '''
fragment ItineraryLine_legs on Leg {
  mode
  rentedBike
  startTime
  endTime
  distance
  legGeometry {
    points
  }
  transitLeg
  route {
    shortName
    color
    agency {
      name
      id
    }
    id
  }
  from {
    lat
    lon
    name
    vertexType
    bikeRentalStation {
      lat
      lon
      stationId
      networks
      bikesAvailable
      id
    }
    stop {
      gtfsId
      code
      platformCode
      id
    }
  }
  to {
    lat
    lon
    name
    vertexType
    bikeRentalStation {
      lat
      lon
      stationId
      networks
      bikesAvailable
      id
    }
    stop {
      gtfsId
      code
      platformCode
      id
    }
  }
  trip {
    stoptimes {
      stop {
        gtfsId
        id
      }
      pickupType
    }
    id
  }
  intermediatePlaces {
    arrivalTime
    stop {
      gtfsId
      lat
      lon
      name
      code
      platformCode
      id
    }
  }
}
''',
);

final itinerarySummaryListFragment = gql(
  '''
fragment ItinerarySummaryListContainer_itineraries on Itinerary {
  walkDistance
  startTime
  endTime
  legs {
    interlineWithPreviousLeg
    alerts {
      alertId
    }
    realTime
    realtimeState
    transitLeg
    startTime
    endTime
    mode
    distance
    duration
    rentedBike
    intermediatePlace
    intermediatePlaces {
      stop {
        zoneId
        id
      }
    }
    route {
      mode
      shortName
      color
      agency {
        name
        id
      }
      alerts {
        alertSeverityLevel
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
    trip {
      pattern {
        code
        id
      }
      stoptimes {
        realtimeState
        stop {
          gtfsId
          id
        }
        pickupType
      }
      id
    }
    from {
      name
      lat
      lon
      stop {
        gtfsId
        zoneId
        platformCode
        alerts {
          alertSeverityLevel
          effectiveEndDate
          effectiveStartDate
          id
        }
        id
      }
      bikeRentalStation {
        bikesAvailable
        networks
        id
      }
    }
    to {
      stop {
        gtfsId
        zoneId
        alerts {
          alertSeverityLevel
          effectiveEndDate
          effectiveStartDate
          id
        }
        id
      }
      bikePark {
        bikeParkId
        name
        id
      }
      carPark {
        carParkId
        name
        id
      }
    }
  }
}
''',
);

final itineraryTabItineraryFragment = gql(
  '''
fragment ItineraryTab_itinerary on Itinerary {
  walkDistance
  walkTime
  duration
  startTime
  endTime
  arrivedAtDestinationWithRentedBicycle
  fares {
    cents
    components {
      cents
      fareId
      routes {
        agency {
          gtfsId
          fareUrl
          name
          id
        }
        gtfsId
        id
      }
    }
    type
  }
  legs {
    mode
    alerts {
      alertId
      alertDescriptionTextTranslations {
        language
        text
      }
    }
    ...LegAgencyInfo_leg
    from {
      lat
      lon
      name
      vertexType
      bikeRentalStation {
        networks
        bikesAvailable
        lat
        lon
        stationId
        id
      }
      stop {
        gtfsId
        code
        platformCode
        vehicleMode
        zoneId
        alerts {
          alertSeverityLevel
          effectiveEndDate
          effectiveStartDate
          trip {
            pattern {
              code
              id
            }
            id
          }
          alertHeaderText
          alertHeaderTextTranslations {
            text
            language
          }
          alertUrl
          alertUrlTranslations {
            text
            language
          }
          id
        }
        id
      }
    }
    to {
      lat
      lon
      name
      vertexType
      bikeRentalStation {
        lat
        lon
        stationId
        networks
        bikesAvailable
        id
      }
      stop {
        gtfsId
        code
        platformCode
        zoneId
        alerts {
          alertSeverityLevel
          effectiveEndDate
          effectiveStartDate
          trip {
            pattern {
              code
              id
            }
            id
          }
          alertHeaderText
          alertHeaderTextTranslations {
            text
            language
          }
          alertUrl
          alertUrlTranslations {
            text
            language
          }
          id
        }
        id
      }
      bikePark {
        bikeParkId
        name
        id
      }
      carPark {
        carParkId
        name
        id
      }
    }
    pickupBookingInfo {
      message
      contactInfo {
        phoneNumber
        infoUrl
        bookingUrl
      }
    }
    legGeometry {
      length
      points
    }
    intermediatePlaces {
      arrivalTime
      stop {
        gtfsId
        lat
        lon
        name
        code
        platformCode
        zoneId
        id
      }
    }
    realTime
    realtimeState
    transitLeg
    rentedBike
    startTime
    endTime
    interlineWithPreviousLeg
    distance
    duration
    intermediatePlace
    route {
      shortName
      color
      gtfsId
      longName
      desc
      agency {
        gtfsId
        fareUrl
        name
        phone
        id
      }
      alerts {
        alertSeverityLevel
        effectiveEndDate
        effectiveStartDate
        trip {
          pattern {
            code
            id
          }
          id
        }
        alertHeaderText
        alertHeaderTextTranslations {
          text
          language
        }
        alertUrl
        alertUrlTranslations {
          text
          language
        }
        id
      }
      id
    }
    trip {
      gtfsId
      tripHeadsign
      pattern {
        code
        id
      }
      stoptimes {
        pickupType
        realtimeState
        stop {
          gtfsId
          id
        }
      }
      id
    }
  }
}
''',
);

final itineraryTabPlanFragment = gql(
  '''
fragment ItineraryTab_plan on Plan {
  date
}
''',
);

final legAgencyInfoFragment = gql(
  '''
fragment LegAgencyInfo_leg on Leg {
  agency {
    name
    url
    fareUrl
    id
  }
}
''',
);

final routeLinePatternFragment = gql(
  '''
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
''',
);

final stopCardStopFragment = gql(
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

final summaryPageServiceTimeRangeFragment = gql(
  '''
fragment SummaryPage_serviceTimeRange on serviceTimeRange {
  start
  end
}
''',
);

final summaryPageViewerFragment = gql(
  r'''
fragment SummaryPage_viewer_3ZG8s4 on QueryType {
  plan(fromPlace: $fromPlace, toPlace: $toPlace, intermediatePlaces: $intermediatePlaces, numItineraries: $numItineraries, transportModes: $transportModes, date: $date, time: $time, walkReluctance: $walkReluctance, walkBoardCost: $walkBoardCost, minTransferTime: $minTransferTime, walkSpeed: $walkSpeed, maxWalkDistance: $maxWalkDistance, wheelchair: $wheelchair, allowedTicketTypes: $ticketTypes, disableRemainingWeightHeuristic: $disableRemainingWeightHeuristic, arriveBy: $arriveBy, transferPenalty: $transferPenalty, bikeSpeed: $bikeSpeed, optimize: $optimize, triangle: $triangle, itineraryFiltering: $itineraryFiltering, unpreferred: $unpreferred, allowedBikeRentalNetworks: $allowedBikeRentalNetworks, locale: $locale) {
    ...SummaryPlanContainer_plan
    ...ItineraryTab_plan
    from{
      name,
      lat,
      lon,
    }
    to{
      name,
      lon,
      lat,
    }
    itineraries {
      startTime
      endTime
      ...ItineraryTab_itinerary
      ...SummaryPlanContainer_itineraries
      legs {
        interlineWithPreviousLeg
        mode
        ...ItineraryLine_legs
        transitLeg
        legGeometry {
          points
        }
        route {
          gtfsId
          id
        }
        trip {
          gtfsId
          directionId
          stoptimesForDate {
            scheduledDeparture
            pickupType
          }
          pattern {
            ...RouteLine_pattern
            id
          }
          id
        }
        from {
          name
          lat
          lon
          stop {
            gtfsId
            zoneId
            id
          }
          bikeRentalStation {
            bikesAvailable
            networks
            id
          }
        }
        to {
          stop {
            gtfsId
            zoneId
            id
          }
          bikePark {
            bikeParkId
            name
            id
          }
        }
      }
    }
  }
}
''',
);

final summaryPlanContainerItinerariesFragment = gql(
  '''
fragment SummaryPlanContainer_itineraries on Itinerary {
  ...ItinerarySummaryListContainer_itineraries
  endTime
  startTime
  legs {
    interlineWithPreviousLeg
    mode
    to {
      bikePark {
        bikeParkId
        name
        id
      }
    }
    ...ItineraryLine_legs
    transitLeg
    legGeometry {
      points
    }
    route {
      gtfsId
      id
    }
    trip {
      gtfsId
      directionId
      stoptimesForDate {
        scheduledDeparture
      }
      pattern {
        ...RouteLine_pattern
        id
      }
      id
    }
  }
}
''',
);

final summaryPlanContainerPlanFragment = gql(
  '''
fragment SummaryPlanContainer_plan on Plan {
  date
}
''',
);

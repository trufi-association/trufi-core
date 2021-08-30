import 'package:graphql/client.dart';

final bikePublicTransportFragment = gql(
  r'''
fragment bikePlan on QueryType {
  plan(
    fromPlace: $fromPlace, 
    toPlace: $toPlace, 
    transportModes: $bikeAndPublicModes, 
    date: $date, 
    time: $time, 
    maxWalkDistance: $maxWalkDistance,
    numItineraries: $numItineraries, 
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
    ...SummaryPlanContainer_plan
    ...ItineraryTab_plan
    itineraries {
      duration
      startTime
      endTime
      ...ItineraryTab_itinerary
      ...SummaryPlanContainer_itineraries
      legs {
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
          }
          pattern {
            ...RouteLine_pattern
            id
          }
          id
        }
        distance
      }
    }
  }
}
''',
);

final bikeServiceTimeRangeFragment = gql(
  '''
fragment serviceTimeRange on serviceTimeRange {
  start
  end
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

final itineraryTabPlanFragment = gql(
  '''
fragment ItineraryTab_plan on Plan {
  date
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
        name
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
        name
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
    dropOffBookingInfo {
      message
      dropOffMessage
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
      type
      longName
      desc
      url
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
          name
          id
        }
      }
      id
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
      url
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
    url
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
      name
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
      name
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
    url
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
      url
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
          name
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
        name
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

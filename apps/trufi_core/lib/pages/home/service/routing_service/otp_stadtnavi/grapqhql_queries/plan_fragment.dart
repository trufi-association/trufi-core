import 'package:graphql/client.dart';

final planFragment = gql('''
fragment planFragment on Plan {
  date
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
    duration
    walkDistance
    emissionsPerPerson {
      co2
    }
    walkTime
    arrivedAtDestinationWithRentedBicycle
    fares {
      cents
      type
      components {
        cents
        fareId
        routes {
          gtfsId
          id
          agency {
            gtfsId
            fareUrl
            name
            id
          }
        }
      }
    }
    legs {
      mode
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
      dropOffBookingInfo {
        message
        dropOffMessage
        contactInfo {
          phoneNumber
          infoUrl
          bookingUrl
        }
      }
      agency {
        name
        url
        fareUrl
        id
      }
      steps {
        distance
        lon
        lat
        elevationProfile{
          distance
          elevation
        }
        relativeDirection
        absoluteDirection
        streetName
        exit
        stayOn
        area
        bogusName
        walkingBike
      }
      from {
        lat
        lon
        name
        vertexType
        bikeRentalStation {
          id
          networks
          bikesAvailable
          lat
          lon
          stationId
        }
        stop {
          id
          gtfsId
          code
          platformCode
          vehicleMode
          zoneId
          name
          alerts {
            id
            alertSeverityLevel
            effectiveEndDate
            effectiveStartDate
            entities {
              __typename
            }
            alertHeaderText
            alertDescriptionText
            alertUrl
            trip {
              id
              pattern {
                code
                id
              }
            }
            alertHeaderTextTranslations {
              text
              language
            }
            alertUrlTranslations {
              text
              language
            }
          }
        }
      }
      to {
        lat
        lon
        name
        vertexType
        # TODO still to be implemented in upstream OTP
        # vehicleParkingWithEntrance {
        #   vehicleParking {
        #     tags
        #   }
        # }
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
          vehicleMode
          zoneId
          id
          alerts {
            alertSeverityLevel
            effectiveEndDate
            effectiveStartDate
            entities {
              __typename
            }
            alertHeaderText
            alertDescriptionText
            alertUrl
            id
            trip {
              id
              pattern {
                code
                id
              }
            }
            alertHeaderTextTranslations {
              text
              language
            }
            alertUrlTranslations {
              text
              language
            }
          }
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
      route {
        id
        gtfsId
        mode
        shortName
        longName
        color
        type
        desc
        url
        agency {
          id
          gtfsId
          fareUrl
          name
          phone
        }
        alerts {
          id
          alertSeverityLevel
          effectiveEndDate
          effectiveStartDate
          entities {
            __typename
          }
          alertHeaderText
          alertDescriptionText
          alertUrl
          trip {
            id
            pattern {
              id
              code
            }
          }
          alertHeaderTextTranslations {
            text
            language
          }
          alertUrlTranslations {
            text
            language
          }
        }
      }
      trip {
        id
        gtfsId
        tripHeadsign
        directionId
        pattern {
          id
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
            id
            gtfsId
            lat
            lon
            name
            platformCode
            code
            desc
            zoneId
            
            alerts {
              alertSeverityLevel
              effectiveEndDate
              effectiveStartDate
              id
            }
            stops {
              name
              desc
              id
            }
          }
        }
        stoptimes {
          pickupType
          realtimeState
          stop {
            id
            gtfsId
            name
          }
        }
        stoptimesForDate {
          scheduledDeparture
          pickupType
        }
      }
    }
  }
}
''');

// ItineraryListContainer_plan
// ItineraryDetails_plan
// ItineraryDetails_itinerary
// ItineraryListContainer_itineraries
// ItineraryLine_legs
// RouteLine_pattern
final itineraryPageViewer = gql(r'''
fragment ItineraryPage_viewer on Plan {
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
  ...ItineraryListContainer_plan
  ...ItineraryDetails_plan
  itineraries {
    duration
    startTime
    endTime
    ...ItineraryDetails_itinerary
    ...ItineraryListContainer_itineraries
    emissionsPerPerson {
      co2
    }
    legs {
      mode
      ...ItineraryLine_legs
      transitLeg
      legGeometry {
        points
      }
      route {
        gtfsId
        type
        shortName
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
        }
      }
      from {
        name
        lat
        lon
        stop {
          gtfsId
          zoneId
        }
        bikeRentalStation {
          bikesAvailable
          networks
        }
      }
      to {
        stop {
          gtfsId
          zoneId
        }
        bikePark {
          bikeParkId
          name
        }
      }
    }
  }
}
''');

final itineraryDetailsPlan = gql(r'''
  fragment ItineraryDetails_plan on Plan {
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
    date
  }
''');

// LegAgencyInfo_leg
final itineraryDetailsItinerary = gql(r'''
  fragment ItineraryDetails_itinerary on Itinerary {
    walkDistance
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
          }
          gtfsId
        }
      }
      type
    }
    emissionsPerPerson {
      co2
    }
    legs {
      mode
      # TODO still to implemented in upstream OTP
      # alerts {
      #  alertId
      #  alertDescriptionTextTranslations {
      #    language
      #    text
      #  }
      #}
      ...LegAgencyInfo_leg
      from {
        lat
        lon
        name
        vertexType
        bikePark {
          bikeParkId
          name
        }
        bikeRentalStation {
          networks
          bikesAvailable
          lat
          lon
          stationId
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
            alertHeaderText
            alertHeaderTextTranslations {
              text
              language
            }
            alertDescriptionText
            alertDescriptionTextTranslations {
              text
              language
            }
            alertUrl
            alertUrlTranslations {
              text
              language
            }
          }
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
        }
        stop {
          gtfsId
          code
          platformCode
          zoneId
          name
          vehicleMode
          alerts {
            alertSeverityLevel
            effectiveEndDate
            effectiveStartDate
            alertSeverityLevel
            effectiveEndDate
            effectiveStartDate
            alertHeaderText
            alertHeaderTextTranslations {
              text
              language
            }
            alertDescriptionText
            alertDescriptionTextTranslations {
              text
              language
            }
            alertUrl
            alertUrlTranslations {
              text
              language
            }
          }
        }
        bikePark {
          bikeParkId
          name
        }
        carPark {
          carParkId
          name
        }
        # TODO still to update upstream OTP
        # vehicleParkingWithEntrance {
        #  vehicleParking {
        #    tags
        #  }
        #}
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
      steps {
        distance
        lon
        lat
        relativeDirection
        absoluteDirection
        streetName
        exit
        stayOn
        area
        walkingBike
        bogusName
        alerts {
          feed
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
        }
      }
      realTime
      realtimeState
      transitLeg
      rentedBike
      startTime
      endTime
      departureDelay
      arrivalDelay
      mode
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
        url
        desc
        agency {
          gtfsId
          fareUrl
          name
          phone
        }
        alerts {
          alertSeverityLevel
          effectiveEndDate
          effectiveStartDate
          entities {
            __typename
            ... on Route {
              patterns {
                code
              }
            }
          }
          alertHeaderText
          alertHeaderTextTranslations {
            text
            language
          }
          alertDescriptionText
          alertDescriptionTextTranslations {
            text
            language
          }
          alertUrl
          alertUrlTranslations {
            text
            language
          }
        }
      }
      trip {
        gtfsId
        tripHeadsign
        pattern {
          code
        }
        stoptimesForDate {
          headsign
          pickupType
          realtimeState
          stop {
            gtfsId
          }
        }
      }
    }
  }
''');

final legAgencyInfoLeg = gql(r'''
  fragment LegAgencyInfo_leg on Leg {
    agency {
      name
      url
      fareUrl
    }
  }
''');
// ItineraryList_itineraries
// ItineraryLine_legs
// RouteLine_pattern
final itineraryListContainerItineraries = gql(r'''
  fragment ItineraryListContainer_itineraries on Itinerary {
  ...ItineraryList_itineraries
  endTime
  startTime
  legs {
    mode
    to {
      bikePark {
        bikeParkId
        name
      }
    }
    ...ItineraryLine_legs
    transitLeg
    legGeometry {
      points
    }
    route {
      gtfsId
    }
    trip {
      gtfsId
      directionId
      stoptimesForDate {
        scheduledDeparture
      }
      pattern {
        ...RouteLine_pattern
      }
    }
  }
}
''');

final itineraryListItineraries = gql(r'''
  fragment ItineraryList_itineraries on Itinerary{
    walkDistance
    startTime
    endTime
    emissionsPerPerson {
      co2
    }
    legs {
      # Temporarilly commented out, still needed in upstream OTP
      # alerts {
      #  alertId
      # }
      realTime
      departureDelay
      realtimeState
      transitLeg
      startTime
      endTime
      mode
      distance
      duration
      rentedBike
      interlineWithPreviousLeg
      intermediatePlace
      intermediatePlaces {
        stop {
          zoneId
        }
      }
      route {
        mode
        shortName
        type
        color
        agency {
          name
        }
        alerts {
          alertSeverityLevel
          effectiveEndDate
          effectiveStartDate
          entities {
            __typename
            ... on Route {
              patterns {
                code
              }
            }
          }
        }
      }
      trip {
        pattern {
          code
        }
        stoptimes {
          realtimeState
          stop {
            gtfsId
          }
          pickupType
        }
        alerts {
          alertSeverityLevel
          effectiveEndDate
          effectiveStartDate
        }
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
          }
        }
        bikeRentalStation {
          bikesAvailable
          networks
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
          }
        }
        bikePark {
          bikeParkId
          name
        }
        carPark {
          carParkId
          name
        }
      }
    }
  }
''');

final itineraryLineLegs = gql(r'''
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
  interlineWithPreviousLeg
  route {
    shortName
    color
    type
    agency {
      name
    }
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
    }
    stop {
      gtfsId
      code
      platformCode
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
    }
    stop {
      gtfsId
      code
      platformCode
    }
  }
  trip {
    gtfsId
    stoptimes {
      stop {
        gtfsId
      }
      pickupType
    }
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
    }
  }
}
''');

final itineraryPageServiceTimeRange = gql(r'''
      fragment ItineraryPage_serviceTimeRange on serviceTimeRange {
        start
        end
      }
''');

// ItineraryLine_legs
// RouteLine_pattern
final itineraryListContainerPlan = gql(r'''
  fragment ItineraryListContainer_plan on Plan {
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
    date
    itineraries {
      startTime
      endTime
      legs {
        mode
        ...ItineraryLine_legs
        transitLeg
        legGeometry {
          points
        }
        route {
          gtfsId
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
          }
        }
        from {
          name
          lat
          lon
          stop {
            gtfsId
            zoneId
          }
          bikeRentalStation {
            bikesAvailable
            networks
          }
        }
        to {
          stop {
            gtfsId
            zoneId
          }
          bikePark {
            bikeParkId
            name
          }
        }
      }
    }
  }
''');

// StopCardHeaderContainer_stop
final routeLinePattern = gql(r'''
  fragment RouteLine_pattern on Pattern {
    code
    geometry {
      lat
      lon
    }
    route {
      mode
      type
      color
    }
    stops {
      lat
      lon
      name
      gtfsId
      platformCode
      code
      ...StopCardHeaderContainer_stop
    }
  }
''');

final stopCardHeaderContainerStop = gql(r'''
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
    }
    lat
    lon
    stops {
      name
      desc
    }
  }
''');

/// GraphQL queries for OTP 2.7 standard schema.
///
/// OTP 2.7 uses the standard schema with:
/// - plan query with common parameters
/// - itineraries without emissions data (added in 2.8)
/// - Basic booking info support

/// Full plan query for OTP 2.7 with all common parameters.
/// Note: OTP 2.7 does not support BicycleOptimizeType or triangle parameters.
const String otp27PlanQuery = r'''
query plan(
  $fromPlace: String!,
  $toPlace: String!,
  $date: String,
  $time: String,
  $arriveBy: Boolean,
  $numItineraries: Int,
  $searchWindow: Long,
  $pageCursor: String,
  $transportModes: [TransportMode],
  $walkReluctance: Float,
  $walkSpeed: Float,
  $bikeSpeed: Float,
  $wheelchair: Boolean,
  $maxWalkDistance: Float,
  $locale: String
) {
  plan(
    fromPlace: $fromPlace,
    toPlace: $toPlace,
    date: $date,
    time: $time,
    arriveBy: $arriveBy,
    numItineraries: $numItineraries,
    searchWindow: $searchWindow,
    pageCursor: $pageCursor,
    transportModes: $transportModes,
    walkReluctance: $walkReluctance,
    walkSpeed: $walkSpeed,
    bikeSpeed: $bikeSpeed,
    wheelchair: $wheelchair,
    maxWalkDistance: $maxWalkDistance,
    locale: $locale
  ) {
    from {
      name
      lat
      lon
      vertexType
    }
    to {
      name
      lat
      lon
      vertexType
    }
    nextPageCursor
    previousPageCursor
    itineraries {
      startTime
      endTime
      duration
      walkTime
      walkDistance
      waitingTime
      arrivedAtDestinationWithRentedBicycle
      legs {
        mode
        startTime
        endTime
        duration
        distance
        transitLeg
        realTime
        realtimeState
        legGeometry {
          points
        }
        from {
          name
          lat
          lon
          departureTime
          vertexType
          stop {
            gtfsId
            name
            lat
            lon
            code
            platformCode
            zoneId
          }
          bikeRentalStation {
            stationId
            name
            bikesAvailable
            spacesAvailable
          }
        }
        to {
          name
          lat
          lon
          arrivalTime
          vertexType
          stop {
            gtfsId
            name
            lat
            lon
            code
            platformCode
            zoneId
          }
          bikeRentalStation {
            stationId
            name
            bikesAvailable
            spacesAvailable
          }
        }
        route {
          gtfsId
          shortName
          longName
          mode
          type
          color
          textColor
          bikesAllowed
          agency {
            gtfsId
            name
            url
            timezone
            phone
          }
        }
        trip {
          gtfsId
          tripHeadsign
          routeShortName
          directionId
          blockId
          wheelchairAccessible
          bikesAllowed
        }
        intermediatePlaces {
          name
          lat
          lon
          arrivalTime
          departureTime
          stop {
            gtfsId
            name
            code
            platformCode
          }
        }
        steps {
          distance
          relativeDirection
          absoluteDirection
          streetName
          stayOn
          area
          lat
          lon
        }
        headsign
        rentedBike
        interlineWithPreviousLeg
        pickupType
        dropoffType
      }
    }
  }
}
''';

/// Simple plan query for OTP 2.7 with minimal parameters.
const String otp27SimplePlanQuery = r'''
query plan(
  $fromPlace: String!,
  $toPlace: String!,
  $numItineraries: Int,
  $locale: String
) {
  plan(
    fromPlace: $fromPlace,
    toPlace: $toPlace,
    numItineraries: $numItineraries,
    locale: $locale
  ) {
    from {
      name
      lat
      lon
    }
    to {
      name
      lat
      lon
    }
    itineraries {
      startTime
      endTime
      duration
      walkTime
      walkDistance
      legs {
        mode
        startTime
        endTime
        duration
        distance
        transitLeg
        realTime
        legGeometry {
          points
        }
        from {
          name
          lat
          lon
          stop {
            gtfsId
            name
          }
        }
        to {
          name
          lat
          lon
          stop {
            gtfsId
            name
          }
        }
        route {
          gtfsId
          shortName
          longName
          color
          textColor
          agency {
            name
          }
        }
        intermediatePlaces {
          name
          lat
          lon
          stop {
            gtfsId
            name
          }
        }
        headsign
      }
    }
  }
}
''';

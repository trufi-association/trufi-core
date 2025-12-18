/// GraphQL queries for OTP 2.8 standard schema.
///
/// OTP 2.8 uses the standard schema with:
/// - plan query with enhanced parameters
/// - itineraries with emissions data
/// - Enhanced booking info support
/// - Better real-time support

/// Full plan query for OTP 2.8 with all common parameters.
const String otp28PlanQuery = r'''
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
  $maxWalkDistance: Float,
  $wheelchair: Boolean,
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
    maxWalkDistance: $maxWalkDistance,
    wheelchair: $wheelchair,
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
      emissionsPerPerson {
        co2
      }
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
      }
    }
  }
}
''';

/// Simple plan query for OTP 2.8 with minimal parameters.
const String otp28SimplePlanQuery = r'''
query plan(
  $fromPlace: String!,
  $toPlace: String!,
  $date: String,
  $time: String,
  $numItineraries: Int,
  $locale: String
) {
  plan(
    fromPlace: $fromPlace,
    toPlace: $toPlace,
    date: $date,
    time: $time,
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

/// GraphQL queries for OTP 2.4 standard schema.
///
/// OTP 2.4 uses the standard OTP GraphQL schema with:
/// - plan (not trip)
/// - itineraries (not tripPatterns)
/// - route (not line)
/// - agency (not authority)
/// - stops (not quays)

/// Full plan query for OTP 2.4 with all common parameters.
const String otp24PlanQuery = r'''
query plan(
  $fromPlace: String!,
  $toPlace: String!,
  $date: String,
  $time: String,
  $arriveBy: Boolean,
  $numItineraries: Int,
  $transportModes: [TransportMode],
  $walkReluctance: Float,
  $walkSpeed: Float,
  $bikeSpeed: Float,
  $optimize: OptimizeType,
  $triangle: InputTriangle,
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
    transportModes: $transportModes,
    walkReluctance: $walkReluctance,
    walkSpeed: $walkSpeed,
    bikeSpeed: $bikeSpeed,
    optimize: $optimize,
    triangle: $triangle,
    wheelchair: $wheelchair,
    maxWalkDistance: $maxWalkDistance,
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
      waitingTime
      legs {
        mode
        startTime
        endTime
        duration
        distance
        transitLeg
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
            lat
            lon
          }
        }
        to {
          name
          lat
          lon
          stop {
            gtfsId
            name
            lat
            lon
          }
        }
        route {
          gtfsId
          shortName
          longName
          mode
          color
          textColor
          agency {
            gtfsId
            name
            url
          }
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
          }
        }
        headsign
        realTime
        rentedBike
        interlineWithPreviousLeg
      }
    }
  }
}
''';

/// Simple plan query for OTP 2.4 with minimal parameters.
const String otp24SimplePlanQuery = r'''
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
        legGeometry {
          points
        }
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
        }
        headsign
      }
    }
  }
}
''';

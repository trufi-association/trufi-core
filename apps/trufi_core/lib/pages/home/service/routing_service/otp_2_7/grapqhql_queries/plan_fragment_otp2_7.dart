import 'package:graphql/client.dart';

final planFragment2_7 = gql('''
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
      ride
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
            alertHeaderText
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
          zoneId
          id
          alerts {
            alertSeverityLevel
            effectiveEndDate
            effectiveStartDate
            alertHeaderText
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
          alertHeaderText
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

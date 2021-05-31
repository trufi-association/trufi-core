const String utilsSummarySimplePageQuery = r'''
query queryUtils_SummaryPage__Simple_Query(
  $fromPlace: String!
  $toPlace: String!
  $numItineraries: Int!
  $transportModes: [TransportMode!]
) {
    plan(
      fromPlace: $fromPlace
      toPlace: $toPlace
      numItineraries: $numItineraries
      transportModes: $transportModes
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
      itineraries {
        legs{
          duration
          distance,
          mode,
          agency{
            name
          }
          route{
            url
            shortName
            longName
          },
          from{
        		name,
        		lon,
        		lat,
          },
          to{
        		name,
        		lon,
        		lat,
          },
          legGeometry{
          	points,
            length
          },
        },
      }
    }
}
''';

const String utilsSummaryPageQuery = r'''
query queryUtils_SummaryPage_Query(
  $fromPlace: String!
  $toPlace: String!
  $intermediatePlaces: [InputCoordinates!]
  $numItineraries: Int!
  $transportModes: [TransportMode!]
  $date: String!
  $time: String!
  $walkReluctance: Float
  $walkBoardCost: Int
  $minTransferTime: Int
  $walkSpeed: Float
  $maxWalkDistance: Float
  $wheelchair: Boolean
  $ticketTypes: [String]
  $disableRemainingWeightHeuristic: Boolean
  $arriveBy: Boolean
  $transferPenalty: Int
  $bikeSpeed: Float
  $optimize: OptimizeType
  $triangle: InputTriangle
  $itineraryFiltering: Float
  $unpreferred: InputUnpreferred
  $allowedBikeRentalNetworks: [String]
  $locale: String
) {
  viewer {
    ...SummaryPage_viewer_3ZG8s4
  }
  serviceTimeRange {
    ...SummaryPage_serviceTimeRange
  }
}
''';

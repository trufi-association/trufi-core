const String queryBikeSimple = r'''
query queryBikeSimple(
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

const String queryBikePublicTransport = r'''
query query_bike_plan_public(
  $fromPlace: String!
  $toPlace: String!
  $intermediatePlaces: [InputCoordinates!]
  $date: String!
  $time: String!
  $walkReluctance: Float
  $walkBoardCost: Int
  $minTransferTime: Int
  $walkSpeed: Float
  $bikeAndPublicMaxWalkDistance: Float
  $ticketTypes: [String]
  $bikeandPublicDisableRemainingWeightHeuristic: Boolean
  $arriveBy: Boolean
  $transferPenalty: Int
  $bikeSpeed: Float
  $optimize: OptimizeType
  $triangle: InputTriangle
  $itineraryFiltering: Float
  $unpreferred: InputUnpreferred
  $locale: String
  $bikeAndPublicModes: [TransportMode!]
) {
  viewer {
    ...bikePlan
  }
  serviceTimeRange {
    ...serviceTimeRange
  }
}
''';

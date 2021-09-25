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
  $date: String!
  $time: String!
  $bikeAndPublicModes: [TransportMode!]
  $maxWalkDistance: Float
  $numItineraries: Int!
  $arriveBy: Boolean!
  $optimize: OptimizeType
  $triangle: InputTriangle
) {
  viewer {
    ...bikePlan
  }
  serviceTimeRange {
    ...serviceTimeRange
  }
}
''';

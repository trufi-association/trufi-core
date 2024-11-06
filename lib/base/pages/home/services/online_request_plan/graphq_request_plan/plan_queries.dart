const String simplePlanQuery = r'''
query simplePlanQuery(
  $fromPlace: String!
  $toPlace: String!
  $numItineraries: Int!
  $date: String!
  $time: String!
  $debugItineraryFilter: Boolean!
) {
  viewer {
    plan(
      fromPlace: $fromPlace,
      toPlace: $toPlace,
      numItineraries: $numItineraries, 
      date: $date,
      time: $time,
      debugItineraryFilter: $debugItineraryFilter,
      ) {
        ...planFragment
      }
  }
}
''';

const planFragment = r'''
query Points{
    route(id:"arequipa-pe:17445672"){
    id
        patterns{
                vehiclePositions{
                  lastUpdated
                  vehicleId
                  label
                    lat
                    lon
                    label
                }
            }
    }
}
''';
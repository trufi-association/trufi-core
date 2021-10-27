const String simplePlanQuery = r'''
query simplePlanQuery(
  $fromPlace: String!
  $toPlace: String!
  $numItineraries: Int!
  $transportModes: [TransportMode!]
  $date: String!
  $time: String!
  $locale: String
) {
  viewer {
    plan(
      fromPlace: $fromPlace,
      toPlace: $toPlace,
      numItineraries: $numItineraries, 
      transportModes: $transportModes,
      date: $date,
      time: $time,
      locale: $locale
      ) {
        ...planFragment
      }
  }
  serviceTimeRange {
    ...serviceTimeRangeFragment
  }
}
''';

const String advancedPlanQuery = r'''
query advancedPlanQuery(
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
    plan(
      fromPlace: $fromPlace,
      toPlace: $toPlace,
      intermediatePlaces: $intermediatePlaces,
      numItineraries: $numItineraries, 
      transportModes: $transportModes,
      date: $date,
      time: $time,
      walkReluctance: $walkReluctance,
      walkBoardCost: $walkBoardCost,
      minTransferTime: $minTransferTime,
      walkSpeed: $walkSpeed,
      maxWalkDistance: $maxWalkDistance,
      wheelchair: $wheelchair,
      allowedTicketTypes: $ticketTypes,
      disableRemainingWeightHeuristic: $disableRemainingWeightHeuristic,
      arriveBy: $arriveBy,
      transferPenalty: $transferPenalty,
      bikeSpeed: $bikeSpeed,
      optimize: $optimize,
      triangle: $triangle,
      itineraryFiltering: $itineraryFiltering,
      unpreferred: $unpreferred,
      allowedBikeRentalNetworks: $allowedBikeRentalNetworks,
      locale: $locale
      ) {
        ...planFragment
      }
  }
  serviceTimeRange {
    ...serviceTimeRangeFragment
  }
}
''';

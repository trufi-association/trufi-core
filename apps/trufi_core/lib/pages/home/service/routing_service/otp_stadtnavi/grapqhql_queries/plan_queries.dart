// ItineraryPage_viewer
// ItineraryPage_serviceTimeRange
const String planQuery = r'''
query ItineraryQueries_ItineraryPage_Query(
  $fromPlace: String!
  $toPlace: String!
  $intermediatePlaces: [InputCoordinates!]
  $numItineraries: Int!
  $modes: [TransportMode!]
  $date: String
  $time: String
  $walkReluctance: Float
  $walkBoardCost: Int
  $minTransferTime: Int
  $walkSpeed: Float
  $wheelchair: Boolean
  $ticketTypes: [String]
  $arriveBy: Boolean
  $transferPenalty: Int
  $bikeSpeed: Float
  $optimize: OptimizeType
  $itineraryFiltering: Float
  $unpreferred: InputUnpreferred
  $allowedVehicleRentalNetworks: [String]
  $locale: String
  $modeWeight: InputModeWeight
) {
  viewer {
    plan(
      fromPlace: $fromPlace
      toPlace: $toPlace
      intermediatePlaces: $intermediatePlaces
      numItineraries: $numItineraries
      transportModes: $modes
      date: $date
      time: $time
      walkReluctance: $walkReluctance
      walkBoardCost: $walkBoardCost
      minTransferTime: $minTransferTime
      walkSpeed: $walkSpeed
      wheelchair: $wheelchair
      allowedTicketTypes: $ticketTypes
      arriveBy: $arriveBy
      transferPenalty: $transferPenalty
      bikeSpeed: $bikeSpeed
      optimize: $optimize
      itineraryFiltering: $itineraryFiltering
      unpreferred: $unpreferred
      allowedVehicleRentalNetworks: $allowedVehicleRentalNetworks
      locale: $locale
      modeWeight: $modeWeight
    ) {
      ...ItineraryPage_viewer
    }
  }

  serviceTimeRange {
    ...ItineraryPage_serviceTimeRange
  }
}
''';

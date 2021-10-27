const String summaryModesPlanQuery = r'''
query summaryModesPlanQuery(
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
  $wheelchair: Boolean
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
  $shouldMakeWalkQuery: Boolean!
  $shouldMakeBikeQuery: Boolean!
  $shouldMakeCarQuery: Boolean!
  $shouldMakeParkRideQuery: Boolean!
  $shouldMakeOnDemandTaxiQuery: Boolean!
  $showBikeAndPublicItineraries: Boolean!
  $showBikeAndParkItineraries: Boolean!
  $bikeAndPublicModes: [TransportMode!]
  $bikeParkModes: [TransportMode!]
  $carMode: [TransportMode!]
) {
  walkPlan: plan(
    fromPlace: $fromPlace,
    toPlace: $toPlace,
    intermediatePlaces: $intermediatePlaces, 
    transportModes: [{mode: WALK}], 
    date: $date, 
    time: $time, 
    walkSpeed: $walkSpeed, 
    wheelchair: $wheelchair, 
    arriveBy: $arriveBy, 
    locale: $locale,
    ) @include(if: $shouldMakeWalkQuery) {
    ...planFragment
  }

  bikePlan: plan(
    fromPlace: $fromPlace, 
    toPlace: $toPlace, 
    intermediatePlaces: $intermediatePlaces, 
    transportModes: [{mode: BICYCLE}], 
    date: $date, 
    time: $time, 
    walkSpeed: $walkSpeed, 
    arriveBy: $arriveBy, 
    bikeSpeed: $bikeSpeed, 
    optimize: $optimize, 
    triangle: $triangle, 
    locale: $locale,
    ) @include(if: $shouldMakeBikeQuery) {
    ...planFragment
  }
  bikeAndPublicPlan: plan(
    fromPlace: $fromPlace, 
    toPlace: $toPlace, 
    intermediatePlaces: $intermediatePlaces, 
    numItineraries: 6, 
    transportModes: $bikeAndPublicModes, 
    date: $date, 
    time: $time, 
    walkReluctance: $walkReluctance, 
    walkBoardCost: $walkBoardCost, 
    minTransferTime: $minTransferTime, 
    walkSpeed: $walkSpeed, 
    maxWalkDistance: $bikeAndPublicMaxWalkDistance, 
    allowedTicketTypes: $ticketTypes, 
    disableRemainingWeightHeuristic: $bikeandPublicDisableRemainingWeightHeuristic, 
    arriveBy: $arriveBy, 
    transferPenalty: $transferPenalty, 
    bikeSpeed: $bikeSpeed, 
    optimize: $optimize, 
    triangle: $triangle, 
    itineraryFiltering: $itineraryFiltering, 
    unpreferred: $unpreferred, 
    locale: $locale,
    ) @include(if: $showBikeAndPublicItineraries) {
    ...planFragment
  }
  bikeParkPlan: plan(
    fromPlace: $fromPlace, 
    toPlace: $toPlace, 
    intermediatePlaces: $intermediatePlaces, 
    numItineraries: 6, 
    transportModes: $bikeParkModes, 
    date: $date, 
    time: $time, 
    walkReluctance: $walkReluctance, 
    walkBoardCost: $walkBoardCost, 
    minTransferTime: $minTransferTime, 
    walkSpeed: $walkSpeed, 
    maxWalkDistance: $bikeAndPublicMaxWalkDistance, 
    allowedTicketTypes: $ticketTypes, 
    disableRemainingWeightHeuristic: $bikeandPublicDisableRemainingWeightHeuristic, 
    arriveBy: $arriveBy, 
    transferPenalty: $transferPenalty, 
    bikeSpeed: $bikeSpeed, 
    optimize: $optimize, 
    triangle: $triangle, 
    itineraryFiltering: $itineraryFiltering, 
    unpreferred: $unpreferred, 
    locale: $locale,
    ) @include(if: $showBikeAndParkItineraries) {
    ...planFragment
    itineraries {
      legs {
        to {
          bikePark {
            bikeParkId
            name
            id
          }
        }
      }
    }
  }
  carPlan: plan(
    fromPlace: $fromPlace, 
    toPlace: $toPlace, 
    intermediatePlaces: $intermediatePlaces, 
    numItineraries: 6, 
    transportModes: $carMode, 
    date: $date, 
    time: $time, 
    walkReluctance: $walkReluctance, 
    walkBoardCost: $walkBoardCost, 
    minTransferTime: $minTransferTime, 
    walkSpeed: $walkSpeed, 
    maxWalkDistance: $bikeAndPublicMaxWalkDistance, 
    allowedTicketTypes: $ticketTypes, 
    arriveBy: $arriveBy, 
    transferPenalty: $transferPenalty, 
    bikeSpeed: $bikeSpeed, 
    optimize: $optimize, 
    triangle: $triangle, 
    itineraryFiltering: $itineraryFiltering, 
    unpreferred: $unpreferred, 
    locale: $locale,
    ) @include(if: $shouldMakeCarQuery) {
    ...planFragment
    itineraries {
      legs {
        to {
          carPark {
            carParkId
            name
            id
          }
        }
      }
    }
  }
  parkRidePlan: plan(
    fromPlace: $fromPlace, 
    toPlace: $toPlace, 
    intermediatePlaces: $intermediatePlaces, 
    numItineraries: 6, 
    transportModes: [
      { mode: CAR, qualifier: PARK }
      { mode: BUS }
      { mode: RAIL }
      { mode: SUBWAY }
    ], 
    date: $date, 
    time: $time, 
    walkReluctance: $walkReluctance, 
    walkBoardCost: $walkBoardCost, 
    minTransferTime: $minTransferTime, 
    walkSpeed: $walkSpeed, 
    maxWalkDistance: $bikeAndPublicMaxWalkDistance, 
    allowedTicketTypes: $ticketTypes, 
    arriveBy: $arriveBy, 
    transferPenalty: $transferPenalty, 
    bikeSpeed: $bikeSpeed, 
    optimize: $optimize, 
    triangle: $triangle, 
    itineraryFiltering: $itineraryFiltering, 
    unpreferred: $unpreferred,
    locale: $locale,
    ) @include(if: $shouldMakeParkRideQuery) {
    ...planFragment
    itineraries {
      legs {
        to {
          carPark {
            carParkId
            name
            id
          }
        }
      }
    }
  }
  onDemandTaxiPlan: plan(
    fromPlace: $fromPlace
    toPlace: $toPlace
    intermediatePlaces: $intermediatePlaces
    numItineraries: 6
    transportModes: [
      { mode: RAIL }
      { mode: BUS }
      { mode: WALK }
    ]
    date: $date
    time: $time
    walkReluctance: $walkReluctance
    walkBoardCost: $walkBoardCost
    minTransferTime: $minTransferTime
    walkSpeed: $walkSpeed
    maxWalkDistance: $bikeAndPublicMaxWalkDistance
    allowedTicketTypes: $ticketTypes
    disableRemainingWeightHeuristic: $bikeandPublicDisableRemainingWeightHeuristic
    arriveBy: $arriveBy
    transferPenalty: $transferPenalty
    bikeSpeed: $bikeSpeed
    optimize: $optimize
    triangle: $triangle
    itineraryFiltering: $itineraryFiltering
    unpreferred: $unpreferred
    locale: $locale
    searchWindow: 10800
    ) @include(if: $shouldMakeOnDemandTaxiQuery) {
    ...planFragment
    itineraries {
      legs {
        trip {
          tripShortName
        }
      }
    }
  }
}
''';

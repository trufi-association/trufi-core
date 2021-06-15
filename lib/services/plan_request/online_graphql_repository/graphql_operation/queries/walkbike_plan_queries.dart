const String summaryPageWalkBikeQuery = r'''
query SummaryPage_WalkBike_Query(
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
    ...SummaryPlanContainer_plan
    ...ItineraryTab_plan
    itineraries {
      walkDistance
      duration
      startTime
      endTime
      ...ItineraryTab_itinerary
      ...SummaryPlanContainer_itineraries
      legs {
        mode
        ...ItineraryLine_legs
        legGeometry {
          points
        }
        distance
      }
    }
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
    ...SummaryPlanContainer_plan
    ...ItineraryTab_plan
    itineraries {
      duration
      startTime
      endTime
      ...ItineraryTab_itinerary
      ...SummaryPlanContainer_itineraries
      legs {
        mode
        ...ItineraryLine_legs
        legGeometry {
          points
        }
        distance
      }
    }
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
    ...SummaryPlanContainer_plan
    ...ItineraryTab_plan
    itineraries {
      duration
      startTime
      endTime
      ...ItineraryTab_itinerary
      ...SummaryPlanContainer_itineraries
      legs {
        mode
        ...ItineraryLine_legs
        transitLeg
        legGeometry {
          points
        }
        route {
          gtfsId
          id
        }
        trip {
          gtfsId
          directionId
          stoptimesForDate {
            scheduledDeparture
          }
          pattern {
            ...RouteLine_pattern
            id
          }
          id
        }
        distance
      }
    }
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
    ...SummaryPlanContainer_plan
    ...ItineraryTab_plan
    itineraries {
      duration
      startTime
      endTime
      ...ItineraryTab_itinerary
      ...SummaryPlanContainer_itineraries
      legs {
        mode
        ...ItineraryLine_legs
        transitLeg
        legGeometry {
          points
        }
        route {
          gtfsId
          id
        }
        trip {
          gtfsId
          directionId
          stoptimesForDate {
            scheduledDeparture
          }
          pattern {
            ...RouteLine_pattern
            id
          }
          id
        }
        to {
          bikePark {
            bikeParkId
            name
            id
          }
        }
        distance
      }
    }
  }
  carPlan: plan(
    fromPlace: $fromPlace, 
    toPlace: $toPlace, 
    intermediatePlaces: $intermediatePlaces, 
    numItineraries: 6, 
    transportModes: [{mode: CAR}], 
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
    ...SummaryPlanContainer_plan
    ...ItineraryTab_plan
    itineraries {
      duration
      startTime
      endTime
      ...ItineraryTab_itinerary
      ...SummaryPlanContainer_itineraries
      legs {
        startTime
        mode
        ...ItineraryLine_legs
        transitLeg
        legGeometry {
          points
        }
        route {
          gtfsId
          id
        }
        trip {
          gtfsId
          directionId
          stoptimesForDate {
            scheduledDeparture
          }
          pattern {
            ...RouteLine_pattern
            id
          }
          id
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
        distance
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
    locale: $locale
    ) @include(if: $shouldMakeParkRideQuery) {
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
    ...SummaryPlanContainer_plan
    ...ItineraryTab_plan
    itineraries {
      duration
      startTime
      endTime
      ...ItineraryTab_itinerary
      ...SummaryPlanContainer_itineraries
      legs {
        mode
        ...ItineraryLine_legs
        transitLeg
        legGeometry {
          points
        }
        route {
          gtfsId
          id
        }
        trip {
          gtfsId
          directionId
          stoptimesForDate {
            scheduledDeparture
          }
          pattern {
            ...RouteLine_pattern
            id
          }
          id
        }
        to {
          carPark {
            carParkId
            name
            id
          }
          name
        }
        distance
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
      { mode: FLEX, qualifier: EGRESS }
      { mode: FLEX, qualifier: DIRECT }
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
    ) @include(if: $shouldMakeOnDemandTaxiQuery) {
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
    ...SummaryPlanContainer_plan
    ...ItineraryTab_plan
    itineraries {
      ...ItinerarySummaryListContainer_itineraries
      duration
      startTime
      endTime
      ...ItineraryTab_itinerary
      ...SummaryPlanContainer_itineraries
      legs {
        mode
        ...ItineraryLine_legs
        transitLeg
        rentedBike
        distance
        startTime
        endTime
        route {
          url
          mode
          shortName
        }
        legGeometry {
          points
        }
        trip {
          gtfsId
          tripShortName
        }
      }
    }
  }
}
''';

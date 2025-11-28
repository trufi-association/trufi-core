/// Advanced query for fetching trip plans from OTP 2.7.
/// Supports all OTP 2.7 parameters for fine-grained control.
const String advancedTripQuery = r'''
query trip($accessEgressPenalty: [PenaltyForStreetMode!],
 $alightSlackDefault: Int,
 $alightSlackList: [TransportModeSlack],
 $arriveBy: Boolean,
 $banned: InputBanned,
 $bicycleOptimisationMethod: BicycleOptimisationMethod,
 $bikeSpeed: Float,
 $boardSlackDefault: Int,
 $boardSlackList: [TransportModeSlack],
 $bookingTime: DateTime,
 $dateTime: DateTime,
 $filters: [TripFilterInput!],
 $from: Location!,
 $ignoreRealtimeUpdates: Boolean,
 $includePlannedCancellations: Boolean,
 $includeRealtimeCancellations: Boolean,
 $itineraryFilters: ItineraryFilters,
 $locale: Locale,
 $maxAccessEgressDurationForMode: [StreetModeDurationInput!],
 $maxDirectDurationForMode: [StreetModeDurationInput!],
 $maximumAdditionalTransfers: Int,
 $maximumTransfers: Int,
 $modes: Modes,
 $numTripPatterns: Int,
 $pageCursor: String,
 $relaxTransitGroupPriority: RelaxCostInput,
 $searchWindow: Int,
 $timetableView: Boolean,
 $to: Location!,
 $transferPenalty: Int,
 $transferSlack: Int,
 $triangleFactors: TriangleFactors,
 $useBikeRentalAvailabilityInformation: Boolean,
 $via: [TripViaLocationInput!],
 $waitReluctance: Float,
 $walkReluctance: Float,
 $walkSpeed: Float,
 $wheelchairAccessible: Boolean,
 $whiteListed: InputWhiteListed,
 ) {
  trip(
    accessEgressPenalty: $accessEgressPenalty
    alightSlackDefault: $alightSlackDefault
    alightSlackList: $alightSlackList
    arriveBy: $arriveBy
    banned: $banned
    bicycleOptimisationMethod: $bicycleOptimisationMethod
    bikeSpeed: $bikeSpeed
    boardSlackDefault: $boardSlackDefault
    boardSlackList: $boardSlackList
    bookingTime: $bookingTime
    dateTime: $dateTime
    filters: $filters
    from: $from
    ignoreRealtimeUpdates: $ignoreRealtimeUpdates
    includePlannedCancellations: $includePlannedCancellations
    includeRealtimeCancellations: $includeRealtimeCancellations
    itineraryFilters: $itineraryFilters
    locale: $locale
    maxAccessEgressDurationForMode: $maxAccessEgressDurationForMode
    maxDirectDurationForMode: $maxDirectDurationForMode
    maximumAdditionalTransfers: $maximumAdditionalTransfers
    maximumTransfers: $maximumTransfers
    modes: $modes
    numTripPatterns: $numTripPatterns
    pageCursor: $pageCursor
    relaxTransitGroupPriority: $relaxTransitGroupPriority
    searchWindow: $searchWindow
    timetableView: $timetableView
    to: $to
    transferPenalty: $transferPenalty
    transferSlack: $transferSlack
    triangleFactors: $triangleFactors
    useBikeRentalAvailabilityInformation: $useBikeRentalAvailabilityInformation
    via: $via
    waitReluctance: $waitReluctance
    walkReluctance: $walkReluctance
    walkSpeed: $walkSpeed
    wheelchairAccessible: $wheelchairAccessible
    whiteListed: $whiteListed
  ) {
    fromPlace {
      name
      latitude
      longitude
    }
    toPlace {
      name
      latitude
      longitude
    }
    previousPageCursor
    nextPageCursor
    tripPatterns {
      aimedStartTime
      aimedEndTime
      expectedEndTime
      expectedStartTime
      duration
      distance
      walkTime
      streetDistance
      legs {
        id
        mode
        aimedStartTime
        aimedEndTime
        expectedEndTime
        expectedStartTime
        realtime
        distance
        ride
        duration
        fromPlace {
          name
          latitude
          longitude
          quay {
            id
          }
        }
        toPlace {
          name
          latitude
          longitude
          quay {
            id
          }
        }
        intermediateQuays {
          id
          name
          latitude
          longitude
          description
          stopPlace {
            latitude
            longitude
            name
            id
          }
        }
        toEstimatedCall {
          destinationDisplay {
            frontText
          }
        }
        line {
          publicCode
          name
          id
          presentation {
            colour
            textColour
          }
        }
        authority {
          name
          id
        }
        pointsOnLink {
          points
        }
        interchangeTo {
          staySeated
        }
        interchangeFrom {
          staySeated
        }
      }
      systemNotices {
        tag
      }
    }
  }
}
''';

/// Simple query for fetching trip plans from OTP 2.7.
/// Uses only basic parameters.
const String simpleTripQuery = r'''
query trip(
  $from: Location!,
  $to: Location!,
  $numTripPatterns: Int,
  $locale: Locale
) {
  trip(
    from: $from
    to: $to
    numTripPatterns: $numTripPatterns
    locale: $locale
  ) {
    fromPlace {
      name
      latitude
      longitude
    }
    toPlace {
      name
      latitude
      longitude
    }
    tripPatterns {
      aimedStartTime
      aimedEndTime
      expectedEndTime
      expectedStartTime
      duration
      distance
      walkTime
      streetDistance
      legs {
        id
        mode
        aimedStartTime
        aimedEndTime
        expectedEndTime
        expectedStartTime
        realtime
        distance
        ride
        duration
        fromPlace {
          name
          latitude
          longitude
        }
        toPlace {
          name
          latitude
          longitude
        }
        intermediateQuays {
          id
          name
          latitude
          longitude
        }
        toEstimatedCall {
          destinationDisplay {
            frontText
          }
        }
        line {
          publicCode
          name
          id
          presentation {
            colour
            textColour
          }
        }
        authority {
          name
          id
        }
        pointsOnLink {
          points
        }
        interchangeTo {
          staySeated
        }
        interchangeFrom {
          staySeated
        }
      }
    }
  }
}
''';

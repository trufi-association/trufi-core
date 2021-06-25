import 'package:trufi_core/l10n/trufi_localization.dart';

enum PlanInfoBox {
  originOutsideService,
  destinationOutsideService,
  noRouteOriginSameAsDestination,
  noRouteOriginNearDestination,
  walkBikeItinerary1,
  walkBikeItinerary2,
  walkBikeItinerary3,
  noRouteMsgWithChanges,
  noRouteMsg,
  usingDefaultTransports,
  undefined,
}

PlanInfoBox getPlanInfoBoxByKey(String key) {
  return PlanInfoBoxExtension.names.keys.firstWhere(
    (keyE) => keyE.name == key,
    orElse: () => PlanInfoBox.undefined,
  );
}

extension PlanInfoBoxExtension on PlanInfoBox {
  static const names = <PlanInfoBox, String>{
    PlanInfoBox.originOutsideService: 'ORIGIN_OUTSIDE_SERVICE',
    PlanInfoBox.destinationOutsideService: 'DESTINATION_OUTSIDE_SERVICE',
    PlanInfoBox.noRouteOriginSameAsDestination:
        'NO_ROUTE_ORIGIN_SAME_AS_DESTINATION',
    PlanInfoBox.noRouteOriginNearDestination:
        'NO_ROUTE_ORIGIN_NEAR_DESTINATION',
    PlanInfoBox.walkBikeItinerary1: 'WALK_BIKE_ITINERARY1',
    PlanInfoBox.walkBikeItinerary2: 'WALK_BIKE_ITINERARY2',
    PlanInfoBox.walkBikeItinerary3: 'WALK_BIKE_ITINERARY3',
    PlanInfoBox.noRouteMsgWithChanges: 'NO_ROUTE_MSG_WITH_CHANGES',
    PlanInfoBox.noRouteMsg: 'NO_ROUTE_MSG',
    PlanInfoBox.usingDefaultTransports: 'USING_DEFAULT_TRANSPORTS',
    PlanInfoBox.undefined: 'UNDEFINED',
  };

  String get name => names[this];

  String translateValue(TrufiLocalization localization) {
    switch (this) {
      case PlanInfoBox.originOutsideService:
        // TODO translate
        return 'originOutsideService';
        break;
      case PlanInfoBox.destinationOutsideService:
        // TODO translate
        return 'destinationOutsideService';
        break;
      case PlanInfoBox.noRouteOriginSameAsDestination:
        // TODO translate
        return 'noRouteOriginSameAsDestination';
        break;
      case PlanInfoBox.noRouteOriginNearDestination:
        // TODO translate
        return 'noRouteOriginNearDestination';
        break;
      case PlanInfoBox.walkBikeItinerary1:
        // TODO translate
        return 'walkBikeItinerary1';
        break;
      case PlanInfoBox.walkBikeItinerary2:
        // TODO translate
        return 'walkBikeItinerary2';
        break;
      case PlanInfoBox.walkBikeItinerary3:
        // TODO translate
        return 'walkBikeItinerary3';
        break;
      case PlanInfoBox.noRouteMsgWithChanges:
        // TODO translate
        return 'noRouteMsgWithChanges';
        break;
      case PlanInfoBox.noRouteMsg:
        // TODO translate
        return 'noRouteMsg';
        break;
      case PlanInfoBox.usingDefaultTransports:
        // TODO translate
        return 'Keine Routenvorschläge mit Ihren Einstelllungen gefunden. Stattdessen haben wird die folgenden Reiseoptionen gefunden:';
        break;
      default:
        return localization.commonError;
    }
  }
}

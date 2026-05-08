import 'service_hours.dart';

/// Resolves a route id to its [ServiceHours] when the host app has
/// access to a GTFS source.
///
/// OTP's REST/GraphQL APIs don't expose calendar+frequencies in a
/// shape we can use to derive operating hours per route, so providers
/// like [Otp15RoutingProvider] / [Otp28RoutingProvider] return [Leg]s
/// with `serviceHours == null`. The [RoutePlannerCubit] takes an
/// optional [ServiceHoursLookup] and uses it as a side-channel to
/// enrich those legs after the parse — typically backed by the same
/// GTFS asset bundled with the app.
abstract class ServiceHoursLookup {
  /// Returns operating hours for [routeId], or null when the lookup
  /// has no record of it (different feed, missing calendar, etc.).
  ///
  /// Implementations should be tolerant of provider-specific id
  /// shapes: OTP returns `feedId:routeId` whereas the bundled GTFS
  /// uses bare `routeId`, so a robust implementation tries both.
  ServiceHours? serviceHoursForRouteId(String routeId);
}

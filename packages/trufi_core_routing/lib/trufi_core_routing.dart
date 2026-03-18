/// A Flutter package for route planning with OTP (OpenTripPlanner) integration.
///
/// This is a pure routing package without UI dependencies.
/// For map visualization, use this package with trufi_core_maps separately.
library;

// ============================================
// Models
// ============================================
export 'src/models/agency.dart';
export 'src/models/itinerary.dart';
export 'src/models/itinerary_group.dart';
export 'src/models/leg.dart';
export 'src/models/place.dart';
export 'src/models/plan.dart';
export 'src/models/plan_location.dart';
export 'src/models/realtime_state.dart';
export 'src/models/route.dart';
export 'src/models/routing_location.dart';
export 'src/models/step.dart';
export 'src/models/stop.dart';
export 'src/models/transit_route.dart';
export 'src/models/transport_mode.dart';
export 'src/models/vertex_type.dart';

// ============================================
// Utilities
// ============================================
export 'src/providers/otp_2_4/graphql_client_factory.dart';
export 'src/utils/polyline_decoder.dart';

// ============================================
// ROUTING PROVIDERS - Common
// ============================================
export 'src/routing_engine_manager.dart';
export 'src/providers/routing_provider.dart';

// ============================================
// ROUTING PROVIDERS - OTP 1.5 (REST API)
// ============================================
export 'src/providers/otp_1_5/otp_15_routing_provider.dart';
export 'src/providers/otp_1_5/otp_1_5_response_parser.dart';

// ============================================
// ROUTING PROVIDERS - OTP 2.4 (GraphQL)
// ============================================
export 'src/providers/otp_2_4/otp_24_routing_provider.dart';
export 'src/providers/otp_2_4/otp_2_4_queries.dart';
export 'src/providers/otp_2_4/otp_2_4_pattern_queries.dart';
export 'src/providers/otp_2_4/otp_2_4_response_parser.dart';

// ============================================
// ROUTING PROVIDERS - OTP 2.8 (GraphQL)
// ============================================
export 'src/providers/otp_2_8/otp_28_routing_provider.dart';
export 'src/providers/otp_2_8/otp_2_8_queries.dart';
export 'src/providers/otp_2_8/otp_2_8_response_parser.dart';

// ============================================
// Localizations
// ============================================
export 'l10n/routing_localizations.dart';

// ============================================
// TRUFI PLANNER (local + remote routing)
// ============================================
export 'src/providers/trufi_planner/trufi_planner_provider.dart';
export 'src/providers/trufi_planner/trufi_planner_config.dart';
export 'src/providers/trufi_planner/trufi_planner_data_source.dart';

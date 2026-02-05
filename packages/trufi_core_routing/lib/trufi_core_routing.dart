/// A Flutter package for route planning with OTP (OpenTripPlanner) integration.
///
/// This package provides:
/// - **Domain Layer**: Business logic (entities, repositories, services)
/// - **Data Layer**: OTP implementations (REST API for 1.5, GraphQL for 2.4, 2.8)
///
/// This is a pure routing package without UI dependencies.
/// For map visualization, use this package with trufi_core_maps separately.
library;

// ============================================
// DOMAIN LAYER - Entities
// ============================================
export 'src/domain/entities/agency.dart';
export 'src/domain/entities/itinerary.dart';
export 'src/domain/entities/itinerary_group.dart';
export 'src/domain/entities/leg.dart';
export 'src/domain/entities/place.dart';
export 'src/domain/entities/plan.dart';
export 'src/domain/entities/plan_location.dart';
export 'src/domain/entities/realtime_state.dart';
export 'src/domain/entities/route.dart';
export 'src/domain/entities/routing_location.dart';
export 'src/domain/entities/step.dart';
export 'src/domain/entities/stop.dart';
export 'src/domain/entities/transit_route.dart';
export 'src/domain/entities/transport_mode.dart';
export 'src/domain/entities/vertex_type.dart';
export 'src/domain/entities/routing_preferences.dart';
export 'src/domain/entities/routing_capabilities.dart';

// ============================================
// DOMAIN LAYER - Repositories
// ============================================
export 'src/domain/repositories/plan_repository.dart';
export 'src/domain/repositories/map_route_repository.dart';
export 'src/domain/repositories/transit_route_repository.dart';

// ============================================
// DOMAIN LAYER - Services
// ============================================
export 'src/domain/services/routing_service.dart';
export 'src/domain/services/routing_preferences_manager.dart';

// ============================================
// DOMAIN LAYER - Utilities
// ============================================
export 'src/domain/utils/itinerary_signature.dart';

// ============================================
// DATA LAYER - GraphQL Utilities
// ============================================
export 'src/data/graphql/graphql_client_factory.dart';
export 'src/data/graphql/polyline_decoder.dart';

// ============================================
// DATA LAYER - OTP Configuration & Version Selection
// ============================================
export 'src/otp_configuration.dart';
export 'src/data/otp_version.dart';

// ============================================
// DATA LAYER - OTP 1.5 Implementation (REST API)
// ============================================
export 'src/data/otp_1_5/otp_1_5_plan_repository.dart';
export 'src/data/otp_1_5/otp_1_5_response_parser.dart';

// ============================================
// DATA LAYER - OTP 2.4 Implementation
// ============================================
export 'src/data/otp_2_4/otp_2_4_plan_repository.dart';
export 'src/data/otp_2_4/otp_2_4_queries.dart';
export 'src/data/otp_2_4/otp_2_4_pattern_queries.dart';
export 'src/data/otp_2_4/otp_2_4_response_parser.dart';
export 'src/data/otp_2_4/otp_2_4_transit_route_repository.dart';

// ============================================
// DATA LAYER - OTP 2.8 Implementation
// ============================================
export 'src/data/otp_2_8/otp_2_8_plan_repository.dart';
export 'src/data/otp_2_8/otp_2_8_queries.dart';
export 'src/data/otp_2_8/otp_2_8_response_parser.dart';

// ============================================
// DATA LAYER - Storage
// ============================================
export 'src/data/storage/local_storage.dart';
export 'src/data/storage/storage_map_route_repository.dart';

// ============================================
// ROUTING PROVIDERS
// ============================================
export 'src/routing_configuration.dart';
export 'src/routing_engine_manager.dart';
export 'src/providers/routing_provider.dart';
export 'src/providers/otp_28_routing_provider.dart';
export 'src/providers/otp_24_routing_provider.dart';
export 'src/providers/otp_15_routing_provider.dart';

// ============================================
// GTFS ROUTING (offline routing)
// ============================================
export 'src/providers/gtfs/gtfs_routing_provider.dart';
export 'src/providers/gtfs/gtfs_routing_config.dart';
export 'src/providers/gtfs/gtfs_data_source.dart';
export 'src/providers/gtfs/parser/gtfs_parser.dart';
export 'src/providers/gtfs/data/gtfs_plan_repository.dart';
export 'src/providers/gtfs/data/gtfs_transit_route_repository.dart';
export 'src/providers/gtfs/models/gtfs_models.dart';
export 'src/providers/gtfs/index/gtfs_spatial_index.dart';
export 'src/providers/gtfs/index/gtfs_route_index.dart';
export 'src/providers/gtfs/index/gtfs_schedule_index.dart';

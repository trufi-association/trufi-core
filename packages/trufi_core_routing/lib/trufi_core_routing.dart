/// A Flutter package for route planning with OTP (OpenTripPlanner) integration.
///
/// This package follows a 3-layer architecture:
/// - **Presentation Layer**: Route display widgets (planned)
/// - **Domain Layer**: Business logic (entities, repositories)
/// - **Data Layer**: OTP GraphQL services
library;

// ============================================
// DOMAIN LAYER - Entities
// ============================================
export 'src/domain/entities/agency.dart';
export 'src/domain/entities/itinerary.dart';
export 'src/domain/entities/itinerary_leg.dart';
export 'src/domain/entities/place.dart';
export 'src/domain/entities/plan.dart';
export 'src/domain/entities/plan_location.dart';
export 'src/domain/entities/realtime_state.dart';
export 'src/domain/entities/route.dart';
export 'src/domain/entities/routing_location.dart';
export 'src/domain/entities/step.dart';
export 'src/domain/entities/transport_mode.dart';
export 'src/domain/entities/vertex_type.dart';

// ============================================
// DOMAIN LAYER - Repositories
// ============================================
export 'src/domain/repositories/plan_repository.dart';
export 'src/domain/repositories/map_route_repository.dart';

// ============================================
// DOMAIN LAYER - Services
// ============================================
export 'src/domain/services/routing_service.dart';

// ============================================
// DATA LAYER - GraphQL Utilities
// ============================================
export 'src/data/graphql/graphql_client_factory.dart';
export 'src/data/graphql/polyline_decoder.dart';

// ============================================
// DATA LAYER - OTP Implementation
// ============================================
export 'src/data/otp/otp_plan_repository.dart';
export 'src/data/otp/otp_queries.dart';
export 'src/data/otp/otp_response_parser.dart';

// ============================================
// DATA LAYER - Storage
// ============================================
export 'src/data/storage/local_storage.dart';
export 'src/data/storage/storage_map_route_repository.dart';

// ============================================
// PRESENTATION LAYER - Routing Map
// ============================================
export 'src/presentation/routing_map/leg_marker_factory.dart';
export 'src/presentation/routing_map/routing_map_layer.dart';
export 'src/presentation/routing_map/routing_map_controller.dart';

// ============================================
// PRESENTATION LAYER - Adapters
// ============================================
export 'src/presentation/adapters/routing_location_adapter.dart';

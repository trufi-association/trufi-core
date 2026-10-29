/// Home screen with route planning for Trufi apps.
///
/// This package provides a complete home screen solution with route planning:
///
/// - **RoutePlannerCubit**: State management for route planning
/// - **HomeScreenRepository**: Interface for local storage
/// - **HomeScreenRepositoryImpl**: Default implementation using StorageService
/// - **RequestPlanService**: Abstract interface for routing requests
/// - **RoutingRequestPlanService**: Implementation using trufi_core_routing
/// - **HomeScreen**: Main home screen widget
/// - **HomeScreenTrufiScreen**: TrufiScreen integration for modular apps
///
/// ## Usage
///
/// ```dart
/// // Using TrufiScreen for modular apps
/// final homeScreen = HomeScreenTrufiScreen(
///   config: HomeScreenConfig(
///     otpEndpoint: 'https://your-otp-server.com',
///     defaultLatitude: -17.3988354,
///     defaultLongitude: -66.1626903,
///   ),
/// );
/// ```
library;

// Models
export 'src/models/route_planner_state.dart';
export 'src/models/vehicle_eta_state.dart';

// Repository
export 'src/repository/home_screen_repository.dart';
export 'src/repository/home_screen_repository_impl.dart';

// Services
export 'src/services/request_plan_service.dart';
export 'src/services/saved_route_snapshot.dart';

// Cubit (State Management)
export 'src/cubit/route_planner_cubit.dart';
export 'src/cubit/vehicle_eta_cubit.dart';

// Widgets
export 'src/widgets/home_screen.dart';
export 'src/widgets/eta_badge.dart';
export 'src/widgets/eta_refresh_button.dart';
export 'src/widgets/live_vehicle_info_panel.dart';
export 'src/widgets/poi_compact_card.dart';
export 'src/widgets/itinerary_card.dart';
export 'src/widgets/itinerary_detail_screen.dart';
export 'src/widgets/itinerary_list.dart';
export 'src/widgets/save_route_button.dart';

// TrufiScreen Integration
export 'src/home_screen_trufi_screen.dart';

// Configuration
export 'src/config/home_screen_config.dart';

// Localizations
export 'l10n/home_screen_localizations.dart';

/// UI extensions for trufi_core_routing.
///
/// This package provides:
/// - **TransportModeUI**: Colors, icons, and images for transport modes
/// - **LegUI**: Colors, formatting for legs
/// - **ItineraryUI**: Compression, formatting for itineraries
/// - **RouteBadge**: The line badge (mode icon + short name on the route
///   colour) every screen draws, with the shared colour helpers
/// - **SVG Icons**: Custom transport icons (bus, rail, walk, etc.)
///
/// This package depends on trufi_core_routing for domain entities.
/// Import trufi_core_routing separately for domain entities.
library;

// UI Extensions
export 'src/transport_mode_ui.dart';
export 'src/leg_ui.dart';
export 'src/itinerary_ui.dart';

// Live / real-time UI
export 'src/live_bus_badge.dart';

// Line badge shared by the routes list, the route detail, the itinerary
// legs, nearby lines and saved routes.
export 'src/route_badge.dart';

// SVG Icons
export 'src/icons/transport_icons.dart';

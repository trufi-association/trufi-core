/// UI extensions for trufi_core_routing.
///
/// This package provides:
/// - **TransportModeUI**: Colors, icons, and images for transport modes
/// - **LegUI**: Colors, formatting for legs
/// - **ItineraryUI**: Compression, formatting for itineraries
/// - **SVG Icons**: Custom transport icons (bus, rail, walk, etc.)
///
/// This package depends on trufi_core_routing for domain entities.
/// Import trufi_core_routing separately for domain entities.
library;

// UI Extensions
export 'src/transport_mode_ui.dart';
export 'src/leg_ui.dart';
export 'src/itinerary_ui.dart';

// SVG Icons
export 'src/icons/transport_icons.dart';

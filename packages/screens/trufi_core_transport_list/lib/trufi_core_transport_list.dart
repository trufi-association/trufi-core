// Models
export 'src/models/transport_route.dart';

// Data provider interface
export 'src/transport_list_data_provider.dart';

// OTP Data provider (connects to OpenTripPlanner)
export 'src/otp_transport_data_provider.dart';

// GTFS Data provider (reads from local GTFS zip asset)
export 'src/gtfs_transport_data_provider.dart';

// Cache (persistence)
export 'src/repository/transport_list_cache.dart';

// Screens
export 'src/transport_list_content.dart';
export 'src/transport_detail_screen.dart';
export 'src/transport_list_trufi_screen.dart';

// Widgets
export 'src/widgets/transport_tile.dart';
export 'src/widgets/transport_detail_sheet.dart';
// The count pill heads both lists (tests find it by type); the
// loading / empty / error states stay internal.
export 'src/widgets/route_count_indicator.dart';

// Nearby lines (#1006): offline discovery by distance radius
export 'src/nearby/nearby_radius.dart';
export 'src/nearby/nearby_line.dart';
export 'src/nearby/nearby_geometry.dart';
export 'src/nearby/nearby_lines_service.dart';
export 'src/nearby/nearby_lines_data_source.dart';
export 'src/nearby/nearby_lines_cubit.dart';
export 'src/nearby/nearby_lines_trufi_screen.dart';
export 'src/nearby/widgets/nearby_lines_sheet.dart';
export 'src/nearby/widgets/nearby_header_card.dart';

// Localizations
export 'l10n/transport_list_localizations.dart';

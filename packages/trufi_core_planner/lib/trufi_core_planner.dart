/// Core GTFS parsing and routing library for Trufi.
/// Pure Dart implementation without Flutter dependencies.
library trufi_core_planner;

// Models
export 'src/models/gtfs_agency.dart';
export 'src/models/gtfs_calendar.dart';
export 'src/models/gtfs_frequency.dart';
export 'src/models/gtfs_route.dart';
export 'src/models/gtfs_shape.dart';
export 'src/models/gtfs_stop.dart';
export 'src/models/gtfs_stop_time.dart';
export 'src/models/gtfs_trip.dart';

// Parser
export 'src/parser/csv_parser.dart';
export 'src/parser/gtfs_parser.dart';

// Index
export 'src/index/gtfs_spatial_index.dart';
export 'src/index/gtfs_route_index.dart';
export 'src/index/gtfs_schedule_index.dart';

// Services
export 'src/services/gtfs_routing_service.dart';

// Client
export 'src/client/planner_routing_client.dart';
export 'src/client/local_planner_client.dart';
export 'src/client/remote_planner_client.dart';

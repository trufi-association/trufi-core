/// A Flutter package for map rendering with maplibre_gl.
///
/// This package follows a 3-layer architecture:
/// - **Presentation Layer**: Map widgets (TrufiMap, TrufiMapLibreMap)
/// - **Domain Layer**: Business logic (TrufiMapController, TrufiLayer, entities)
/// - **Data Layer**: Data access (tile fetching, spatial indexing, utilities)
/// - **Configuration**: Map configuration, markers, and copyright
library;

// ============================================
// CONFIGURATION
// ============================================
export 'src/configuration/map_configuration.dart';
export 'src/configuration/marker_configuration.dart';
export 'src/configuration/map_copyright.dart';
export 'src/configuration/map_layer/map_layer.dart';
export 'src/configuration/map_layer/map_layer_local_storage.dart';
export 'src/configuration/map_layer/map_layers_cubit.dart';
export 'src/configuration/map_layer/map_layer_storage_impl.dart';
export 'src/configuration/markers/from_marker.dart';
export 'src/configuration/markers/to_marker.dart';
export 'src/configuration/markers/my_location_marker.dart';
export 'src/configuration/map_engine/trufi_map_engine.dart';
export 'src/configuration/map_engine/maplibre_engine.dart';
export 'src/configuration/map_engine/map_engine_manager.dart';
export 'src/configuration/map_engine/default_map_engines.dart';

// ============================================
// DOMAIN LAYER - Entities
// ============================================
export 'src/domain/entities/bounds.dart';
export 'src/domain/entities/camera.dart';
export 'src/domain/entities/marker.dart';
export 'src/domain/entities/line.dart';

// ============================================
// DOMAIN LAYER - Controller
// ============================================
export 'src/domain/controller/map_controller.dart';

// ============================================
// DOMAIN LAYER - Layers
// ============================================
export 'src/domain/layers/trufi_layer.dart';
export 'src/domain/layers/layer_utils.dart';
export 'src/domain/layers/fit_camera_layer.dart';

// ============================================
// PRESENTATION LAYER - Map Widgets
// ============================================
export 'src/presentation/map/trufi_map.dart';
export 'src/presentation/map/maplibre_map.dart';

// ============================================
// PRESENTATION LAYER - Utils
// ============================================
export 'src/presentation/utils/trufi_camera_fit.dart';

// ============================================
// PRESENTATION LAYER - Widgets
// ============================================
export 'src/presentation/widgets/map_type_button.dart';
export 'src/presentation/widgets/map_type_option.dart';
export 'src/presentation/widgets/map_type_settings_screen.dart';
export 'src/presentation/widgets/choose_on_map_screen.dart';

// ============================================
// DATA LAYER - Tile System
// ============================================
export 'src/data/tile/tile_utils.dart';
export 'src/data/tile/tile_grid_layer.dart';
export 'src/data/tile/cached_fetch.dart';

// ============================================
// DATA LAYER - Spatial Indexing
// ============================================
export 'src/data/spatial/marker_index.dart';

// ============================================
// DATA LAYER - Utilities
// ============================================
export 'src/data/utils/image_tool.dart';
export 'src/data/utils/color_utils.dart';
export 'src/data/utils/sorted_list.dart';

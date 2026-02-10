import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart' as planner;

// Re-export GtfsData from trufi_core_planner
export 'package:trufi_core_planner/trufi_core_planner.dart' show GtfsData;

/// Flutter-specific GTFS parser that wraps trufi_core_planner.
/// Adds support for Flutter assets and isolate-based parsing.
class GtfsParser {
  /// Parse a GTFS ZIP file from Flutter assets.
  static Future<planner.GtfsData> parseFromAsset(String assetPath) async {
    final sw = Stopwatch()..start();
    debugPrint('GtfsParser: Loading GTFS from $assetPath');

    final bytes = await rootBundle.load(assetPath);
    final data = bytes.buffer.asUint8List();

    // Parse in isolate to avoid blocking UI
    final result = await compute(planner.GtfsParser.parseFromBytes, data);

    sw.stop();
    debugPrint('GtfsParser: Parsed GTFS in ${sw.elapsedMilliseconds}ms');
    debugPrint('GtfsParser: ${result.stops.length} stops, ${result.routes.length} routes, ${result.trips.length} trips');

    return result;
  }

  /// Parse GTFS data from raw bytes (synchronous).
  /// Use this when already in an isolate or for testing.
  static planner.GtfsData parseFromBytes(Uint8List data) {
    return planner.GtfsParser.parseFromBytes(data);
  }
}

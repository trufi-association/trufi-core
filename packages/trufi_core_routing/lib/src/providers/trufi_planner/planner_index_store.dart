/// Where the local planner caches its built index between cold starts
/// (#993). The platform implementation (`dart:io` + `path_provider`) is
/// selected at compile time; on web — where the local planner is not used —
/// the stub reports "no cache" and `TrufiPlannerDataSource` builds as
/// before. Keeping `dart:io` behind this import is what lets
/// `trufi_core_routing` keep compiling for `flutter build web`.
library;

import 'dart:typed_data';

import 'planner_index_store_stub.dart'
    if (dart.library.io) 'planner_index_store_io.dart'
    as impl;

/// Absolute path of the snapshot file for [gtfsAsset], or null when the
/// platform has nowhere to put it. Must run on the root isolate
/// (`path_provider` is a platform channel).
Future<String?> plannerIndexCachePath(String gtfsAsset) =>
    impl.plannerIndexCachePath(gtfsAsset);

/// The whole snapshot file, or null when it does not exist or cannot be
/// read. Synchronous on purpose: it runs inside the loading isolate.
Uint8List? readPlannerIndexSync(String path) => impl.readPlannerIndexSync(path);

/// Writes [bytes] atomically (temp file + rename) so a crash mid-write can
/// never leave a half snapshot in place. Throws on I/O failure.
Future<void> writePlannerIndex(String path, Uint8List bytes) =>
    impl.writePlannerIndex(path, bytes);

/// Removes the snapshot if present. Never throws.
Future<void> deletePlannerIndex(String path) => impl.deletePlannerIndex(path);

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path_provider/path_provider.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

/// `<app cache dir>/trufi_planner/<asset basename>-<hash>.idx`.
///
/// The **cache** directory, not application support: Android Auto Backup
/// excludes `getCacheDir()` and caps an app's backup at 25 MB — the
/// Cochabamba snapshot alone is ~38 MB, and a file that size under
/// `getFilesDir()` would make the whole app backup fail (preferences, saved
/// places). iOS likewise leaves `Library/Caches` out of iCloud backups and
/// may purge it under disk pressure, which is fine: the snapshot is rebuilt
/// from the bundled GTFS. Same location the offline map extraction uses.
Future<String?> plannerIndexCachePath(String gtfsAsset) async {
  final dir = await getApplicationCacheDirectory();
  final base = gtfsAsset
      .split('/')
      .last
      .replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
  final key = PlannerIndexCodec.fingerprint(utf8.encode(gtfsAsset));
  return '${dir.path}/trufi_planner/$base-$key.idx';
}

Uint8List? readPlannerIndexSync(String path) {
  try {
    final file = File(path);
    if (!file.existsSync()) return null;
    return file.readAsBytesSync();
  } catch (_) {
    return null;
  }
}

/// Test seam: awaited once the temp file is fully written and before it is
/// renamed into place, so a test can pin the atomic sequence and hold the
/// write to check that the planner was ready before it. Null in production.
@visibleForTesting
Future<void> Function(String tmpPath, String path)?
debugBeforePlannerIndexRename;

Future<void> writePlannerIndex(String path, Uint8List bytes) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await _deleteStaleTemps(file);
  // Unique temp name: two writers of the same snapshot (two providers over
  // one asset) must not truncate each other's file mid-write.
  final tmp = File('$path.$pid.${DateTime.now().microsecondsSinceEpoch}.tmp');
  try {
    await tmp.writeAsBytes(bytes, flush: true);
    await debugBeforePlannerIndexRename?.call(tmp.path, path);
    await tmp.rename(path);
  } catch (_) {
    // Disk full, permissions, a concurrent writer that swept our temp file…
    // never leave a partial snapshot behind on an already tight disk.
    try {
      if (await tmp.exists()) await tmp.delete();
    } catch (_) {
      // Nothing more to do; the caller logs the original failure.
    }
    rethrow;
  }
}

/// Temp files of this very snapshot left by a run killed mid-write (unique
/// names would otherwise accumulate). A concurrent writer's file in flight
/// is swept too: its rename then fails and is logged, and the snapshot on
/// disk is the other writer's — still complete and valid.
Future<void> _deleteStaleTemps(File file) async {
  final prefix = '${file.path}.';
  try {
    await for (final entry in file.parent.list()) {
      if (entry is File &&
          entry.path.startsWith(prefix) &&
          entry.path.endsWith('.tmp')) {
        try {
          await entry.delete();
        } catch (_) {
          // Best effort.
        }
      }
    }
  } catch (_) {
    // Best effort: an unreadable directory fails the write itself later.
  }
}

Future<void> deletePlannerIndex(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) await file.delete();
  } catch (_) {
    // Best effort: a stale file is rejected by its header on the next read.
  }
}

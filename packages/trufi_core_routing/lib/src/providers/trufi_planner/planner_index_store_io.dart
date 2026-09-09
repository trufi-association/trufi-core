import 'dart:io';
import 'dart:typed_data';

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
  final key = PlannerIndexCodec.fingerprint(
    Uint8List.fromList(gtfsAsset.codeUnits),
  );
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

Future<void> writePlannerIndex(String path, Uint8List bytes) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  final tmp = File('$path.tmp');
  await tmp.writeAsBytes(bytes, flush: true);
  await tmp.rename(path);
}

Future<void> deletePlannerIndex(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) await file.delete();
  } catch (_) {
    // Best effort: a stale file is rejected by its header on the next read.
  }
}

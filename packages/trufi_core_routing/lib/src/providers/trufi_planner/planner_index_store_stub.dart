// Web (no `dart:io`): the local planner does not run here, and there is no
// file system to cache into — every call reports "no cache".
import 'dart:typed_data';

Future<String?> plannerIndexCachePath(String gtfsAsset) async => null;

Uint8List? readPlannerIndexSync(String path) => null;

Future<void> writePlannerIndex(String path, Uint8List bytes) async {}

Future<void> deletePlannerIndex(String path) async {}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// The persisted planner index end to end through [TrufiPlannerDataSource]
/// (#993): real files in a temp cache directory, the GTFS served through a
/// mocked asset bundle, the worker isolate as in production.
class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getApplicationCachePath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const asset = 'assets/routing/test.gtfs.zip';
  // The planner package's fixture: a cut of the real Sana'a feed. Tests run
  // from the package root (melos / CI do), hence the relative path.
  final fixture = File(
    '../trufi_core_planner/test/fixtures/sanaa_issue2_mini.gtfs.zip',
  );
  late Uint8List zip;
  late Directory tempDir;
  late Map<String, Uint8List> assets;

  setUpAll(() {
    expect(
      fixture.existsSync(),
      isTrue,
      reason: 'run from packages/trufi_core_routing: ${fixture.absolute.path}',
    );
    zip = fixture.readAsBytesSync();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('planner-index-');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    assets = {asset: zip};
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(
            message!.buffer.asUint8List(
              message.offsetInBytes,
              message.lengthInBytes,
            ),
          );
          final bytes = assets[key];
          return bytes == null ? null : ByteData.sublistView(bytes);
        });
  });

  tearDown(() async {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    await tempDir.delete(recursive: true);
  });

  Directory cacheDir() => Directory('${tempDir.path}/trufi_planner');

  List<File> snapshotFiles() => cacheDir().existsSync()
      ? cacheDir().listSync().whereType<File>().toList()
      : const [];

  File snapshotFile() {
    final files = snapshotFiles().where((f) => f.path.endsWith('.idx'));
    expect(files, hasLength(1), reason: 'exactly one snapshot per asset');
    return files.single;
  }

  Future<TrufiPlannerDataSource> preload({bool persist = true}) async {
    final source = TrufiPlannerDataSource(
      config: TrufiPlannerConfig.local(
        gtfsAsset: asset,
        maxWalkingDistance: 1500,
        persistIndex: persist,
      ),
    );
    await source.preload();
    expect(source.isLoaded, isTrue, reason: source.errorMessage);
    await source.pendingSnapshotWrite;
    return source;
  }

  /// The reporter's trips from trufi-sanaa#2, planned through the client.
  Future<List<String>> plan(TrufiPlannerDataSource source) async {
    const pairs = <(LatLng, LatLng)>[
      (LatLng(15.29408, 44.26392), LatLng(15.33736, 44.19833)),
      (LatLng(15.33736, 44.19833), LatLng(15.29408, 44.26392)),
      (LatLng(15.2952334, 44.2623529), LatLng(15.3536032, 44.1786948)),
      (LatLng(15.3536032, 44.1786948), LatLng(15.2952334, 44.2623529)),
    ];
    final out = <String>[];
    for (final (from, to) in pairs) {
      final paths = await source.client.findRoutes(
        origin: from,
        destination: to,
        maxWalkDistance: 1500,
      );
      out.add(
        paths
            .map(
              (p) =>
                  '${p.originStop.id}>'
                  '${p.segments.map((s) => '${s.route.id}/${s.pattern.id}/${s.fromIdx}-${s.toIdx}').join('+')}'
                  '>${p.destinationStop.id}@${p.score.toStringAsFixed(6)}',
            )
            .join(','),
      );
    }
    return out;
  }

  /// A different but valid GTFS: the fixture without its last route.
  Uint8List withoutLastRoute(Uint8List original) {
    final archive = ZipDecoder().decodeBytes(original);
    final out = Archive();
    for (final file in archive) {
      if (!file.isFile) continue;
      var content = file.content as List<int>;
      if (file.name.endsWith('routes.txt')) {
        final lines = utf8
            .decode(content)
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .toList();
        lines.removeLast();
        content = utf8.encode('${lines.join('\n')}\n');
      }
      out.addFile(ArchiveFile(file.name, content.length, content));
    }
    return Uint8List.fromList(ZipEncoder().encode(out));
  }

  test(
    'first start builds and persists; the next cold start loads the snapshot '
    'and plans identically',
    () async {
      final first = await preload();
      final info1 = first.lastIndexLoad!;
      expect(info1.source, PlannerIndexSource.built);
      expect(info1.buildTimings, isNotNull);
      expect(info1.snapshotBytes, greaterThan(10000));
      expect(info1.rejectedBecause, isNull, reason: 'no snapshot yet');
      final file = snapshotFile();
      expect(file.lengthSync(), info1.snapshotBytes);
      expect(
        snapshotFiles().where((f) => f.path.endsWith('.tmp')),
        isEmpty,
        reason: 'temp file renamed into place',
      );
      expect(file.path, contains('test.gtfs.zip-'));

      final second = await preload();
      final info2 = second.lastIndexLoad!;
      expect(info2.source, PlannerIndexSource.cache);
      expect(info2.buildTimings, isNull);
      expect(info2.snapshotBytes, info1.snapshotBytes);
      expect(info2.fingerprint, info1.fingerprint);
      expect(second.pendingSnapshotWrite, isNull, reason: 'nothing to write');
      expect(file.lengthSync(), info1.snapshotBytes, reason: 'not rewritten');

      expect(
        second.routeIndex!.connectionCount,
        first.routeIndex!.connectionCount,
      );
      expect(second.data!.stops.length, first.data!.stops.length);
      final plannedFromBuild = await plan(first);
      expect(plannedFromBuild.where((s) => s.isNotEmpty), hasLength(4));
      expect(await plan(second), orderedEquals(plannedFromBuild));
      expect(
        second.getNextDepartures(first.data!.stops.keys.first, limit: 3).length,
        first.getNextDepartures(first.data!.stops.keys.first, limit: 3).length,
      );
      expect('${info2}', contains('loaded from cache'));
    },
  );

  test('a changed GTFS asset is detected and the snapshot replaced', () async {
    final first = await preload();
    final before = snapshotFile().lengthSync();
    final routesBefore = first.data!.routes.length;

    assets[asset] = withoutLastRoute(zip);
    final second = await preload();
    final info = second.lastIndexLoad!;
    expect(info.source, PlannerIndexSource.built);
    expect(info.rejectedBecause, contains('fingerprint'));
    expect(info.fingerprint, isNot(first.lastIndexLoad!.fingerprint));
    expect(
      second.data!.routes.length,
      routesBefore - 1,
      reason: 'the planner uses the new feed, not the stale snapshot',
    );
    expect(snapshotFile().lengthSync(), isNot(before));

    final third = await preload();
    expect(third.lastIndexLoad!.source, PlannerIndexSource.cache);
    expect(third.data!.routes.length, routesBefore - 1);
  });

  test('a corrupt snapshot is rebuilt silently and overwritten', () async {
    await preload();
    final file = snapshotFile();
    final bytes = file.readAsBytesSync();
    // Flip one byte deep in the payload, keep the size.
    bytes[bytes.length ~/ 2] ^= 0x40;
    file.writeAsBytesSync(bytes, flush: true);

    final rebuilt = await preload();
    expect(rebuilt.lastIndexLoad!.source, PlannerIndexSource.built);
    expect(rebuilt.lastIndexLoad!.rejectedBecause, contains('checksum'));
    expect(rebuilt.status, TrufiPlannerDataStatus.loaded);
    expect((await plan(rebuilt)).where((s) => s.isNotEmpty), hasLength(4));

    final again = await preload();
    expect(again.lastIndexLoad!.source, PlannerIndexSource.cache);
  });

  test('a truncated snapshot and garbage are rebuilt too', () async {
    await preload();
    final file = snapshotFile();
    final bytes = file.readAsBytesSync();
    file.writeAsBytesSync(bytes.sublist(0, bytes.length ~/ 3), flush: true);
    expect((await preload()).lastIndexLoad!.source, PlannerIndexSource.built);
    expect((await preload()).lastIndexLoad!.source, PlannerIndexSource.cache);

    file.writeAsBytesSync(List.filled(4096, 0x5a), flush: true);
    final rebuilt = await preload();
    expect(rebuilt.lastIndexLoad!.source, PlannerIndexSource.built);
    expect(rebuilt.lastIndexLoad!.rejectedBecause, isNotNull);
  });

  test('a snapshot from another format version is rebuilt', () async {
    await preload();
    final file = snapshotFile();
    final bytes = file.readAsBytesSync();
    ByteData.sublistView(
      bytes,
    ).setUint32(4, PlannerIndexCodec.formatVersion + 1, Endian.host);
    file.writeAsBytesSync(bytes, flush: true);
    final rebuilt = await preload();
    expect(rebuilt.lastIndexLoad!.source, PlannerIndexSource.built);
    expect(rebuilt.lastIndexLoad!.rejectedBecause, contains('format version'));
    expect((await preload()).lastIndexLoad!.source, PlannerIndexSource.cache);
  });

  test(
    'other index knobs mean another snapshot (rebuilt, then reused)',
    () async {
      await preload();
      final source = TrufiPlannerDataSource(
        config: const TrufiPlannerConfig.local(
          gtfsAsset: asset,
          transferRadiusMeters: 0,
        ),
      );
      await source.preload();
      await source.pendingSnapshotWrite;
      expect(source.lastIndexLoad!.source, PlannerIndexSource.built);
      expect(
        source.lastIndexLoad!.rejectedBecause,
        contains('transferRadiusMeters'),
      );
      expect(source.routeIndex!.transferRadiusMeters, 0);
    },
  );

  test('persistIndex: false never touches the disk', () async {
    final source = await preload(persist: false);
    expect(source.lastIndexLoad!.source, PlannerIndexSource.built);
    expect(source.lastIndexLoad!.snapshotBytes, 0);
    expect(source.pendingSnapshotWrite, isNull);
    expect(cacheDir().existsSync(), isFalse);
    expect(
      (await preload(persist: false)).lastIndexLoad!.source,
      PlannerIndexSource.built,
    );
  });

  test('no cache directory available: builds without persisting', () async {
    PathProviderPlatform.instance = _ThrowingPathProvider();
    final source = await preload();
    expect(source.isLoaded, isTrue);
    expect(source.lastIndexLoad!.source, PlannerIndexSource.built);
    expect(source.lastIndexLoad!.snapshotBytes, 0);
    expect(cacheDir().existsSync(), isFalse);
  });

  test('clear() forgets the load diagnostics', () async {
    final source = await preload();
    expect(source.lastIndexLoad, isNotNull);
    source.clear();
    expect(source.lastIndexLoad, isNull);
    expect(source.status, TrufiPlannerDataStatus.unloaded);
  });
}

class _ThrowingPathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationCachePath() async =>
      throw MissingPluginException('no path_provider here');
}

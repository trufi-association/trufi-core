import 'dart:convert';
import 'dart:typed_data';

import '../index/gtfs_route_index.dart';
import '../index/gtfs_schedule_index.dart';
import '../index/gtfs_spatial_index.dart';
import '../models/gtfs_agency.dart';
import '../models/gtfs_calendar.dart';
import '../models/gtfs_frequency.dart';
import '../models/gtfs_route.dart';
import '../models/gtfs_shape.dart';
import '../models/gtfs_stop.dart';
import '../models/gtfs_stop_time.dart';
import '../models/gtfs_trip.dart';
import '../parser/gtfs_parser.dart';
import 'planner_index_bundle.dart';

/// Thrown by [PlannerIndexCodec.encode] when a bundle holds a value the
/// format cannot represent losslessly (never for data produced by
/// [GtfsParser]; the caller then simply does not cache).
class PlannerIndexEncodeException implements Exception {
  final String message;

  const PlannerIndexEncodeException(this.message);

  @override
  String toString() => 'PlannerIndexEncodeException: $message';
}

/// Binary snapshot of a [PlannerIndexBundle], so a cold start can skip the
/// GTFS parse and every index build (#993).
///
/// One blob holds the whole in-memory state: the parsed [GtfsData] in
/// columnar sections over a deduplicated string pool, the patterns, the CSR
/// transfer table of [GtfsRouteIndex] as raw columns, the KD-tree of
/// [GtfsSpatialIndex] as its pre-order, and the sorted stop-time groups of
/// [GtfsScheduleIndex]. Restoring is a linear pass that allocates the model
/// objects and calls the `restore` constructors; nothing is parsed, sorted
/// or searched. On the desktop VM the Cochabamba feed shipped by trufi-app
/// builds in ~1.6 s (parse 1.1 s of it) and decodes in a fraction of that.
///
/// Layout (host byte order — the file is a local cache and never travels):
///
/// ```
/// 'TPIX' · formatVersion u32 · byte-order marker u32 · reserved u32
/// transferRadiusMeters f64 · sameNameRouteLimit i32 · fingerprint (u32 + utf8)
/// payloadLength u32 · payloadChecksum u32 · payload (sections) · 'XIPT'
/// ```
///
/// Each section starts 8-byte aligned (typed-data views require offsets
/// that are multiples of the element size) with a tag and its byte length;
/// integer columns are stored with the narrowest width their maximum fits
/// (1, 2 or 4 bytes) and widened to `Int32List` on load. Coordinates,
/// `cumDist` and `shape_dist_traveled` are `Float64`, GTFS times are
/// `Int32` seconds, dates are microseconds since the epoch as `Float64`
/// (exact below 2^53) plus a UTC flag — the round trip is lossless.
///
/// Every integer operation is 32-bit (`_mul32`, masks), because dart2js
/// compiles all reachable code and 64-bit literals broke `flutter build web`
/// once already (#980); the codec never runs on web, but it must compile.
///
/// [decode] answers `null` for anything it will not vouch for — wrong magic
/// or trailer, another [formatVersion], different knobs or fingerprint,
/// checksum mismatch, truncation, or any index out of range while
/// restoring — and the caller rebuilds from the GTFS.
class PlannerIndexCodec {
  /// Version of the snapshot schema **and** of the index-building rules it
  /// captures. Bump it whenever the layout changes or when
  /// [GtfsRouteIndex], [GtfsSpatialIndex] or [GtfsScheduleIndex] would build
  /// something different from the same GTFS (thinning rule, line keys, tree
  /// shape, sort order…): a snapshot written by the previous version is then
  /// rejected and rebuilt instead of serving stale indices — the failure
  /// mode of the asset-extraction cache in #973. A test pins a digest of the
  /// integer columns of a fixture snapshot to catch a forgotten bump.
  static const int formatVersion = 1;

  static const List<int> _magic = [0x54, 0x50, 0x49, 0x58]; // 'TPIX'
  static const List<int> _trailer = [0x58, 0x49, 0x50, 0x54]; // 'XIPT'
  static const int _byteOrderMarker = 0x01020304;

  static const int _tagStrings = 1;
  static const int _tagAgencies = 2;
  static const int _tagStops = 3;
  static const int _tagRoutes = 4;
  static const int _tagTrips = 5;
  static const int _tagStopTimes = 6;
  static const int _tagCalendars = 7;
  static const int _tagCalendarDates = 8;
  static const int _tagFrequencies = 9;
  static const int _tagShapes = 10;
  static const int _tagPatterns = 11;
  static const int _tagConnections = 12;
  static const int _tagSpatial = 13;
  static const int _tagSchedule = 14;

  static const int _int32Max = 0x7fffffff;
  static const int _int32Min = -0x80000000;

  /// Content fingerprint of a GTFS asset: two independent 32-bit FNV-1a
  /// streams over 32-bit words (plus the byte length), as 16 hex digits.
  /// JS-safe arithmetic only (see [_mul32]). Word-wise hashing keeps it at
  /// ~6 ms for a 5 MB zip on the desktop VM (per-byte FNV takes 20 ms).
  /// Non-cryptographic on purpose: the question is "is this the same
  /// bundled file", not adversarial integrity.
  static String fingerprint(Uint8List bytes) {
    var h1 = 0x811c9dc5;
    var h2 = 0xcbf29ce4;
    final data = ByteData.sublistView(bytes);
    final words = bytes.length & ~3;
    for (var i = 0; i < words; i += 4) {
      final w = data.getUint32(i, Endian.little);
      h1 = _mul32(h1 ^ w, 0x01000193);
      h2 = _mul32(h2 ^ (w ^ 0x5f5f5f5f), 0x01000193);
    }
    for (var i = words; i < bytes.length; i++) {
      h1 = _mul32(h1 ^ bytes[i], 0x01000193);
      h2 = _mul32(h2 ^ bytes[i] ^ 0x5f, 0x01000193);
    }
    h1 = _mul32(h1 ^ (bytes.length & 0xffffffff), 0x01000193);
    h2 = _mul32(h2 ^ (bytes.length & 0xffffffff), 0x01000193);
    return h1.toRadixString(16).padLeft(8, '0') +
        h2.toRadixString(16).padLeft(8, '0');
  }

  /// 32-bit multiply modulo 2^32 with no intermediate above 2^53, identical
  /// on the VM and under dart2js (same trick as trufi_core_maps, #980).
  static int _mul32(int a, int b) {
    final hi = (((a >>> 16) & 0xffff) * b) & 0xffff;
    final lo = (a & 0xffff) * b;
    return ((hi << 16) + lo) & 0xffffffff;
  }

  /// FNV-1a over the 32-bit words of `bytes[start, end)`; `end - start`
  /// must be a multiple of 4 (payloads are 8-aligned).
  static int _checksum(Uint8List bytes, int start, int end) {
    final data = ByteData.sublistView(bytes, start, end);
    var h = 0x811c9dc5;
    for (var i = 0; i < data.lengthInBytes; i += 4) {
      h = _mul32(h ^ data.getUint32(i, Endian.host), 0x01000193);
    }
    return h;
  }

  // ---------------------------------------------------------------------
  // Encode
  // ---------------------------------------------------------------------

  /// Serializes [bundle]. [fingerprint] is the [PlannerIndexCodec.fingerprint]
  /// of the GTFS the bundle was built from; [decode] only accepts the blob
  /// for the same fingerprint and the same knobs
  /// ([GtfsRouteIndex.transferRadiusMeters], [GtfsRouteIndex.sameNameRouteLimit]).
  ///
  /// Throws [PlannerIndexEncodeException] for values outside the format
  /// (an `int` beyond 32 bits, a `Duration` that is not whole seconds, a
  /// pattern whose `cumDist` is missing) — none of which [GtfsParser] and
  /// the index builders produce.
  static Uint8List encode(
    PlannerIndexBundle bundle, {
    required String fingerprint,
  }) {
    final pool = _StringPool();
    final body = _Writer();
    _writeBody(body, bundle, pool);

    final out = _Writer();
    out.rawBytes(_magic);
    out.u32(formatVersion);
    out.u32(_byteOrderMarker);
    out.u32(0); // reserved
    out.f64(bundle.routeIndex.transferRadiusMeters);
    out.i32(_i32(bundle.routeIndex.sameNameRouteLimit, 'sameNameRouteLimit'));
    out.string(fingerprint);
    out.align(8);
    final payloadLengthAt = out.position;
    out.u32(0); // payload length, patched below
    out.u32(0); // payload checksum, patched below
    out.align(8);
    final payloadStart = out.position;
    _writeSection(out, _tagStrings, () => pool.write(out));
    out.rawBytes(body.finish());
    final payloadEnd = out.position;
    out.patchU32(payloadLengthAt, payloadEnd - payloadStart);
    final bytes = out.finish(trailer: _trailer);
    final checksum = _checksum(bytes, payloadStart, payloadEnd);
    ByteData.sublistView(
      bytes,
    ).setUint32(payloadLengthAt + 4, checksum, Endian.host);
    return bytes;
  }

  static void _writeBody(
    _Writer w,
    PlannerIndexBundle bundle,
    _StringPool pool,
  ) {
    final data = bundle.data;

    _writeSection(w, _tagAgencies, () {
      w.u32(data.agencies.length);
      for (final a in data.agencies) {
        w.u32(pool.ref(a.id));
        w.u32(pool.ref(a.name));
        w.u32(pool.ref(a.url));
        w.u32(pool.ref(a.timezone));
        w.u32(pool.ref(a.lang));
        w.u32(pool.ref(a.phone));
        w.u32(pool.ref(a.fareUrl));
        w.u32(pool.ref(a.email));
      }
    });

    final stops = data.stops.values.toList(growable: false);
    _writeSection(w, _tagStops, () {
      final n = stops.length;
      w.u32(n);
      w.uintColumn([for (final s in stops) pool.ref(s.id)]);
      w.uintColumn([for (final s in stops) pool.ref(s.name)]);
      w.uintColumn([for (final s in stops) pool.ref(s.code)]);
      w.uintColumn([for (final s in stops) pool.ref(s.description)]);
      w.uintColumn([for (final s in stops) pool.ref(s.zoneId)]);
      w.uintColumn([for (final s in stops) pool.ref(s.url)]);
      w.uintColumn([for (final s in stops) pool.ref(s.parentStation)]);
      w.uintColumn([for (final s in stops) pool.ref(s.timezone)]);
      w.uintColumn([for (final s in stops) pool.ref(s.platformCode)]);
      w.u8List([for (final s in stops) s.locationType.value]);
      w.u8List([for (final s in stops) s.wheelchairBoarding.value]);
      w.f64Column(n, (i) => stops[i].lat);
      w.f64Column(n, (i) => stops[i].lon);
    });

    final routes = data.routes.values.toList(growable: false);
    _writeSection(w, _tagRoutes, () {
      w.u32(routes.length);
      w.uintColumn([for (final r in routes) pool.ref(r.id)]);
      w.uintColumn([for (final r in routes) pool.ref(r.agencyId)]);
      w.uintColumn([for (final r in routes) pool.ref(r.shortName)]);
      w.uintColumn([for (final r in routes) pool.ref(r.longName)]);
      w.uintColumn([for (final r in routes) pool.ref(r.description)]);
      w.uintColumn([for (final r in routes) pool.ref(r.url)]);
      w.uintColumn([for (final r in routes) pool.ref(r.colorHex)]);
      w.uintColumn([for (final r in routes) pool.ref(r.textColorHex)]);
      w.intColumn([for (final r in routes) r.type.value]);
      w.u8List([for (final r in routes) r.sortOrder == null ? 0 : 1]);
      w.intColumn([
        for (final r in routes) _i32(r.sortOrder ?? 0, 'route_sort_order'),
      ]);
    });

    final trips = data.trips.values.toList(growable: false);
    _writeSection(w, _tagTrips, () {
      w.u32(trips.length);
      w.uintColumn([for (final t in trips) pool.ref(t.id)]);
      w.uintColumn([for (final t in trips) pool.ref(t.routeId)]);
      w.uintColumn([for (final t in trips) pool.ref(t.serviceId)]);
      w.uintColumn([for (final t in trips) pool.ref(t.headsign)]);
      w.uintColumn([for (final t in trips) pool.ref(t.shortName)]);
      w.uintColumn([for (final t in trips) pool.ref(t.blockId)]);
      w.uintColumn([for (final t in trips) pool.ref(t.shapeId)]);
      w.u8List([for (final t in trips) t.directionId?.value ?? 0xff]);
      w.u8List([for (final t in trips) t.wheelchairAccessible.value]);
      w.u8List([for (final t in trips) t.bikesAllowed.value]);
    });

    final stopTimes = data.stopTimes;
    _writeSection(w, _tagStopTimes, () {
      w.u32(stopTimes.length);
      w.uintColumn([for (final st in stopTimes) pool.ref(st.tripId)]);
      w.uintColumn([for (final st in stopTimes) pool.ref(st.stopId)]);
      w.uintColumn([for (final st in stopTimes) pool.ref(st.stopHeadsign)]);
      w.intColumn([
        for (final st in stopTimes) _seconds(st.arrivalTime, 'arrival_time'),
      ]);
      w.intColumn([
        for (final st in stopTimes)
          _seconds(st.departureTime, 'departure_time'),
      ]);
      w.intColumn([
        for (final st in stopTimes) _i32(st.stopSequence, 'stop_sequence'),
      ]);
      w.u8List([for (final st in stopTimes) st.pickupType.value]);
      w.u8List([for (final st in stopTimes) st.dropOffType.value]);
      w.u8List([for (final st in stopTimes) st.timepoint.value]);
      final anyDist = stopTimes.any((st) => st.shapeDistTraveled != null);
      w.u8(anyDist ? 1 : 0);
      if (anyDist) {
        w.u8List([
          for (final st in stopTimes) st.shapeDistTraveled == null ? 0 : 1,
        ]);
        w.f64Column(
          stopTimes.length,
          (i) => stopTimes[i].shapeDistTraveled ?? 0,
        );
      }
    });

    final calendars = data.calendars.values.toList(growable: false);
    _writeSection(w, _tagCalendars, () {
      w.u32(calendars.length);
      for (final c in calendars) {
        w.u32(pool.ref(c.serviceId));
        w.u8(
          (c.monday ? 1 : 0) |
              (c.tuesday ? 2 : 0) |
              (c.wednesday ? 4 : 0) |
              (c.thursday ? 8 : 0) |
              (c.friday ? 16 : 0) |
              (c.saturday ? 32 : 0) |
              (c.sunday ? 64 : 0),
        );
        w.u8(c.startDate.isUtc ? 1 : 0);
        w.u8(c.endDate.isUtc ? 1 : 0);
        w.align(8);
        w.f64(c.startDate.microsecondsSinceEpoch.toDouble());
        w.f64(c.endDate.microsecondsSinceEpoch.toDouble());
      }
    });

    _writeSection(w, _tagCalendarDates, () {
      w.u32(data.calendarDates.length);
      for (final d in data.calendarDates) {
        w.u32(pool.ref(d.serviceId));
        w.u8(d.exceptionType.value);
        w.u8(d.date.isUtc ? 1 : 0);
        w.align(8);
        w.f64(d.date.microsecondsSinceEpoch.toDouble());
      }
    });

    _writeSection(w, _tagFrequencies, () {
      final fs = data.frequencies;
      w.u32(fs.length);
      w.uintColumn([for (final f in fs) pool.ref(f.tripId)]);
      w.intColumn([for (final f in fs) _seconds(f.startTime, 'start_time')]);
      w.intColumn([for (final f in fs) _seconds(f.endTime, 'end_time')]);
      w.intColumn([for (final f in fs) _i32(f.headwaySecs, 'headway_secs')]);
      w.u8List([for (final f in fs) f.exactTimes ? 1 : 0]);
    });

    final shapes = data.shapes.values.toList(growable: false);
    _writeSection(w, _tagShapes, () {
      w.u32(shapes.length);
      w.uintColumn([for (final s in shapes) pool.ref(s.id)]);
      w.uintColumn([for (final s in shapes) s.points.length]);
      final points = [for (final s in shapes) ...s.points];
      w.u32(points.length);
      w.f64Column(points.length, (i) => points[i].lat);
      w.f64Column(points.length, (i) => points[i].lon);
      w.intColumn([for (final p in points) _i32(p.sequence, 'shape_pt_seq')]);
      final anyDist = points.any((p) => p.distTraveled != null);
      w.u8(anyDist ? 1 : 0);
      if (anyDist) {
        w.u8List([for (final p in points) p.distTraveled == null ? 0 : 1]);
        w.f64Column(points.length, (i) => points[i].distTraveled ?? 0);
      }
      for (var i = 0; i < shapes.length; i++) {
        for (final p in shapes[i].points) {
          if (p.shapeId != shapes[i].id) {
            throw PlannerIndexEncodeException(
              'shape ${shapes[i].id} holds a point of shape ${p.shapeId}',
            );
          }
        }
      }
    });

    final index = bundle.routeIndex;
    final patterns = index.patterns.toList(growable: false);
    _writeSection(w, _tagPatterns, () {
      w.u32(patterns.length);
      for (var i = 0; i < patterns.length; i++) {
        final p = patterns[i];
        if (p.id != i) {
          throw PlannerIndexEncodeException(
            'pattern at position $i has id ${p.id}',
          );
        }
        if (p.cumDist.length != p.stopIds.length) {
          throw PlannerIndexEncodeException(
            'pattern $i has ${p.cumDist.length} cumDist for '
            '${p.stopIds.length} stops',
          );
        }
      }
      w.uintColumn([for (final p in patterns) pool.ref(p.routeId)]);
      w.uintColumn([for (final p in patterns) pool.ref(p.headsign)]);
      w.uintColumn([for (final p in patterns) pool.ref(p.shapeId)]);
      w.uintColumn([for (final p in patterns) p.stopIds.length]);
      w.f64List([for (final p in patterns) p.minLat]);
      w.f64List([for (final p in patterns) p.minLon]);
      w.f64List([for (final p in patterns) p.maxLat]);
      w.f64List([for (final p in patterns) p.maxLon]);
      final stopRefs = <int>[];
      final cumDist = <double>[];
      for (final p in patterns) {
        for (final id in p.stopIds) {
          stopRefs.add(pool.ref(id));
        }
        cumDist.addAll(p.cumDist);
      }
      w.u32(stopRefs.length);
      w.uintColumn(stopRefs);
      w.f64List(cumDist);
    });

    _writeSection(w, _tagConnections, () {
      w.uintColumn(index.connectionStarts);
      w.uintColumn(index.connectionOtherPattern);
      w.uintColumn(index.connectionMyStopIdx);
      w.uintColumn(index.connectionOtherStopIdx);
      w.f32List(index.connectionWalk);
    });

    _writeSection(w, _tagSpatial, () {
      final positions = <String, int>{};
      for (var i = 0; i < stops.length; i++) {
        positions[stops[i].id] = i;
      }
      final preorder = bundle.spatialIndex.preorder;
      if (preorder.length != stops.length) {
        throw PlannerIndexEncodeException(
          'spatial index holds ${preorder.length} stops, data ${stops.length}',
        );
      }
      w.uintColumn([
        for (final s in preorder)
          positions[s.id] ??
              (throw PlannerIndexEncodeException(
                'spatial index stop ${s.id} is not in the data',
              )),
      ]);
    });

    _writeSection(w, _tagSchedule, () {
      final positions = Map<GtfsStopTime, int>.identity();
      for (var i = 0; i < stopTimes.length; i++) {
        positions[stopTimes[i]] = i;
      }
      final groups = bundle.scheduleIndex.stopTimesByStop;
      w.u32(groups.length);
      w.uintColumn([for (final key in groups.keys) pool.ref(key)]);
      w.uintColumn([for (final list in groups.values) list.length]);
      final order = <int>[];
      for (final list in groups.values) {
        for (final st in list) {
          order.add(
            positions[st] ??
                (throw PlannerIndexEncodeException(
                  'schedule index holds a stop time that is not in the data',
                )),
          );
        }
      }
      w.u32(order.length);
      w.uintColumn(order);
    });
  }

  static void _writeSection(_Writer w, int tag, void Function() body) {
    w.align(8);
    w.u32(tag);
    final lengthAt = w.position;
    w.u32(0);
    final start = w.position;
    body();
    w.patchU32(lengthAt, w.position - start);
    w.align(8);
  }

  static int _i32(int value, String what) {
    if (value < _int32Min || value > _int32Max) {
      throw PlannerIndexEncodeException('$what $value does not fit 32 bits');
    }
    return value;
  }

  /// GTFS times as whole seconds; `-1` encodes null.
  static int _seconds(Duration? d, String what) {
    if (d == null) return -1;
    final us = d.inMicroseconds;
    if (us % Duration.microsecondsPerSecond != 0) {
      throw PlannerIndexEncodeException('$what $d is not whole seconds');
    }
    return _i32(d.inSeconds, what);
  }

  // ---------------------------------------------------------------------
  // Decode
  // ---------------------------------------------------------------------

  /// Restores the bundle serialized in [bytes], or `null` when the blob is
  /// not a valid snapshot for exactly this input: [fingerprint] must equal
  /// the one given to [encode], [transferRadiusMeters] and
  /// [sameNameRouteLimit] must equal the index's knobs, [formatVersion] must
  /// match, and the blob must be intact (magic, trailer, section lengths,
  /// checksum, every reference in range). Never throws for malformed input;
  /// [onReject] receives a one-line reason when it returns `null`.
  static PlannerIndexBundle? decode(
    Uint8List bytes, {
    required String fingerprint,
    required double transferRadiusMeters,
    required int sameNameRouteLimit,
    void Function(String reason)? onReject,
  }) {
    try {
      return _decode(
        bytes,
        fingerprint: fingerprint,
        transferRadiusMeters: transferRadiusMeters,
        sameNameRouteLimit: sameNameRouteLimit,
      );
    } on _Rejected catch (e) {
      onReject?.call(e.reason);
      return null;
    } catch (e) {
      // RangeError, StateError, FormatException… — a truncated or corrupted
      // blob. The caller rebuilds; the reason is only for the log line.
      onReject?.call('corrupt snapshot: $e');
      return null;
    }
  }

  static PlannerIndexBundle _decode(
    Uint8List input, {
    required String fingerprint,
    required double transferRadiusMeters,
    required int sameNameRouteLimit,
  }) {
    // Typed views need element-aligned offsets into the underlying buffer.
    final bytes = input.offsetInBytes % 8 == 0
        ? input
        : Uint8List.fromList(input);
    final r = _Reader(bytes);
    if (bytes.length < 16) throw const _Rejected('too short');
    for (var i = 0; i < 4; i++) {
      if (r.u8() != _magic[i]) throw const _Rejected('not a planner snapshot');
    }
    for (var i = 0; i < 4; i++) {
      if (bytes[bytes.length - 4 + i] != _trailer[i]) {
        throw const _Rejected('truncated snapshot (no trailer)');
      }
    }
    final version = r.u32();
    if (version != formatVersion) {
      throw _Rejected('format version $version, expected $formatVersion');
    }
    if (r.u32() != _byteOrderMarker) throw const _Rejected('byte order');
    r.u32(); // reserved
    final radius = r.f64();
    final limit = r.i32();
    if (radius != transferRadiusMeters || limit != sameNameRouteLimit) {
      throw _Rejected(
        'built for transferRadiusMeters $radius / sameNameRouteLimit $limit',
      );
    }
    final storedFingerprint = r.string();
    if (storedFingerprint != fingerprint) {
      throw const _Rejected('GTFS fingerprint changed');
    }
    r.align(8);
    final payloadLength = r.u32();
    final checksum = r.u32();
    r.align(8);
    final payloadStart = r.position;
    final payloadEnd = payloadStart + payloadLength;
    if (payloadLength % 8 != 0 || payloadEnd + 4 != bytes.length) {
      throw const _Rejected('payload length does not match the file');
    }
    if (_checksum(bytes, payloadStart, payloadEnd) != checksum) {
      throw const _Rejected('checksum mismatch');
    }

    final pool = _StringPool.read(r, _tagStrings);

    final agencies = r.section(_tagAgencies, () {
      final n = r.u32();
      return List<GtfsAgency>.generate(n, (_) {
        return GtfsAgency(
          id: pool.required(r.u32()),
          name: pool.required(r.u32()),
          url: pool.required(r.u32()),
          timezone: pool.required(r.u32()),
          lang: pool.optional(r.u32()),
          phone: pool.optional(r.u32()),
          fareUrl: pool.optional(r.u32()),
          email: pool.optional(r.u32()),
        );
      });
    });

    final stopList = r.section(_tagStops, () {
      final n = r.u32();
      final id = r.uintColumn(n);
      final name = r.uintColumn(n);
      final code = r.uintColumn(n);
      final desc = r.uintColumn(n);
      final zone = r.uintColumn(n);
      final url = r.uintColumn(n);
      final parent = r.uintColumn(n);
      final tz = r.uintColumn(n);
      final platform = r.uintColumn(n);
      final locationType = r.u8List(n);
      final wheelchair = r.u8List(n);
      final lat = r.f64List(n);
      final lon = r.f64List(n);
      return List<GtfsStop>.generate(n, (i) {
        return GtfsStop(
          id: pool.required(id[i]),
          code: pool.optional(code[i]),
          name: pool.required(name[i]),
          description: pool.optional(desc[i]),
          lat: lat[i],
          lon: lon[i],
          zoneId: pool.optional(zone[i]),
          url: pool.optional(url[i]),
          locationType: GtfsLocationType.fromValue(locationType[i]),
          parentStation: pool.optional(parent[i]),
          timezone: pool.optional(tz[i]),
          wheelchairBoarding: GtfsWheelchairBoarding.fromValue(wheelchair[i]),
          platformCode: pool.optional(platform[i]),
        );
      }, growable: false);
    });
    final stops = <String, GtfsStop>{for (final s in stopList) s.id: s};
    if (stops.length != stopList.length) {
      throw const _Rejected('duplicate stop ids');
    }

    final routeList = r.section(_tagRoutes, () {
      final n = r.u32();
      final id = r.uintColumn(n);
      final agency = r.uintColumn(n);
      final short = r.uintColumn(n);
      final long = r.uintColumn(n);
      final desc = r.uintColumn(n);
      final url = r.uintColumn(n);
      final color = r.uintColumn(n);
      final textColor = r.uintColumn(n);
      final type = r.intColumn(n);
      final hasSort = r.u8List(n);
      final sort = r.intColumn(n);
      return List<GtfsRoute>.generate(n, (i) {
        return GtfsRoute(
          id: pool.required(id[i]),
          agencyId: pool.optional(agency[i]),
          shortName: pool.required(short[i]),
          longName: pool.required(long[i]),
          description: pool.optional(desc[i]),
          type: GtfsRouteType.fromValue(type[i]),
          url: pool.optional(url[i]),
          colorHex: pool.optional(color[i]),
          textColorHex: pool.optional(textColor[i]),
          sortOrder: hasSort[i] == 0 ? null : sort[i],
        );
      }, growable: false);
    });
    final routes = <String, GtfsRoute>{for (final x in routeList) x.id: x};
    if (routes.length != routeList.length) {
      throw const _Rejected('duplicate route ids');
    }

    final tripList = r.section(_tagTrips, () {
      final n = r.u32();
      final id = r.uintColumn(n);
      final route = r.uintColumn(n);
      final service = r.uintColumn(n);
      final headsign = r.uintColumn(n);
      final short = r.uintColumn(n);
      final block = r.uintColumn(n);
      final shape = r.uintColumn(n);
      final direction = r.u8List(n);
      final wheelchair = r.u8List(n);
      final bikes = r.u8List(n);
      return List<GtfsTrip>.generate(n, (i) {
        return GtfsTrip(
          id: pool.required(id[i]),
          routeId: pool.required(route[i]),
          serviceId: pool.required(service[i]),
          headsign: pool.optional(headsign[i]),
          shortName: pool.optional(short[i]),
          directionId: direction[i] == 0xff
              ? null
              : GtfsDirectionId.fromValue(direction[i]),
          blockId: pool.optional(block[i]),
          shapeId: pool.optional(shape[i]),
          wheelchairAccessible: GtfsWheelchairAccessible.fromValue(
            wheelchair[i],
          ),
          bikesAllowed: GtfsBikesAllowed.fromValue(bikes[i]),
        );
      }, growable: false);
    });
    final trips = <String, GtfsTrip>{for (final t in tripList) t.id: t};
    if (trips.length != tripList.length) {
      throw const _Rejected('duplicate trip ids');
    }

    final stopTimes = r.section(_tagStopTimes, () {
      final n = r.u32();
      final trip = r.uintColumn(n);
      final stop = r.uintColumn(n);
      final headsign = r.uintColumn(n);
      final arrival = r.intColumn(n);
      final departure = r.intColumn(n);
      final sequence = r.intColumn(n);
      final pickup = r.u8List(n);
      final dropOff = r.u8List(n);
      final timepoint = r.u8List(n);
      final anyDist = r.u8() != 0;
      final hasDist = anyDist ? r.u8List(n) : null;
      final dist = anyDist ? r.f64List(n) : null;
      return List<GtfsStopTime>.generate(n, (i) {
        return GtfsStopTime(
          tripId: pool.required(trip[i]),
          arrivalTime: _duration(arrival[i]),
          departureTime: _duration(departure[i]),
          stopId: pool.required(stop[i]),
          stopSequence: sequence[i],
          stopHeadsign: pool.optional(headsign[i]),
          pickupType: GtfsPickupType.fromValue(pickup[i]),
          dropOffType: GtfsDropOffType.fromValue(dropOff[i]),
          shapeDistTraveled: hasDist != null && hasDist[i] != 0
              ? dist![i]
              : null,
          timepoint: GtfsTimepoint.fromValue(timepoint[i]),
        );
      }, growable: false);
    });

    final calendarList = r.section(_tagCalendars, () {
      final n = r.u32();
      return List<GtfsCalendar>.generate(n, (_) {
        final serviceId = pool.required(r.u32());
        final days = r.u8();
        final startUtc = r.u8() != 0;
        final endUtc = r.u8() != 0;
        r.align(8);
        final start = _dateTime(r.f64(), startUtc);
        final end = _dateTime(r.f64(), endUtc);
        return GtfsCalendar(
          serviceId: serviceId,
          monday: days & 1 != 0,
          tuesday: days & 2 != 0,
          wednesday: days & 4 != 0,
          thursday: days & 8 != 0,
          friday: days & 16 != 0,
          saturday: days & 32 != 0,
          sunday: days & 64 != 0,
          startDate: start,
          endDate: end,
        );
      });
    });
    final calendars = <String, GtfsCalendar>{
      for (final c in calendarList) c.serviceId: c,
    };
    if (calendars.length != calendarList.length) {
      throw const _Rejected('duplicate service ids');
    }

    final calendarDates = r.section(_tagCalendarDates, () {
      final n = r.u32();
      return List<GtfsCalendarDate>.generate(n, (_) {
        final serviceId = pool.required(r.u32());
        final exception = r.u8();
        final utc = r.u8() != 0;
        r.align(8);
        return GtfsCalendarDate(
          serviceId: serviceId,
          date: _dateTime(r.f64(), utc),
          exceptionType: GtfsExceptionType.fromValue(exception),
        );
      });
    });

    final frequencies = r.section(_tagFrequencies, () {
      final n = r.u32();
      final trip = r.uintColumn(n);
      final start = r.intColumn(n);
      final end = r.intColumn(n);
      final headway = r.intColumn(n);
      final exact = r.u8List(n);
      return List<GtfsFrequency>.generate(n, (i) {
        return GtfsFrequency(
          tripId: pool.required(trip[i]),
          startTime: _duration(start[i]) ?? Duration.zero,
          endTime: _duration(end[i]) ?? Duration.zero,
          headwaySecs: headway[i],
          exactTimes: exact[i] != 0,
        );
      });
    });

    final shapes = r.section(_tagShapes, () {
      final n = r.u32();
      final id = r.uintColumn(n);
      final counts = r.uintColumn(n);
      final total = r.u32();
      final lat = r.f64List(total);
      final lon = r.f64List(total);
      final sequence = r.intColumn(total);
      final anyDist = r.u8() != 0;
      final hasDist = anyDist ? r.u8List(total) : null;
      final dist = anyDist ? r.f64List(total) : null;
      final out = <String, GtfsShape>{};
      var at = 0;
      for (var i = 0; i < n; i++) {
        final shapeId = pool.required(id[i]);
        final count = counts[i];
        if (at + count > total) throw const _Rejected('shape points overflow');
        final points = List<GtfsShapePoint>.generate(count, (k) {
          final j = at + k;
          return GtfsShapePoint(
            shapeId: shapeId,
            lat: lat[j],
            lon: lon[j],
            sequence: sequence[j],
            distTraveled: hasDist != null && hasDist[j] != 0 ? dist![j] : null,
          );
        });
        at += count;
        out[shapeId] = GtfsShape(id: shapeId, points: points);
      }
      if (at != total || out.length != n) {
        throw const _Rejected('shape table inconsistent');
      }
      return out;
    });

    final data = GtfsData(
      agencies: agencies,
      stops: stops,
      routes: routes,
      trips: trips,
      stopTimes: stopTimes,
      calendars: calendars,
      calendarDates: calendarDates,
      frequencies: frequencies,
      shapes: shapes,
    );

    final patterns = r.section(_tagPatterns, () {
      final n = r.u32();
      final route = r.uintColumn(n);
      final headsign = r.uintColumn(n);
      final shape = r.uintColumn(n);
      final counts = r.uintColumn(n);
      final minLat = r.f64List(n);
      final minLon = r.f64List(n);
      final maxLat = r.f64List(n);
      final maxLon = r.f64List(n);
      final total = r.u32();
      final stopRefs = r.uintColumn(total);
      final cumDist = r.f64List(total);
      final out = <RoutePattern>[];
      var at = 0;
      for (var i = 0; i < n; i++) {
        final count = counts[i];
        if (at + count > total) throw const _Rejected('pattern stops overflow');
        final stopIds = List<String>.generate(
          count,
          (k) => pool.required(stopRefs[at + k]),
          growable: false,
        );
        out.add(
          RoutePattern(
            id: i,
            routeId: pool.required(route[i]),
            stopIds: stopIds,
            headsign: pool.optional(headsign[i]),
            shapeId: pool.optional(shape[i]),
            cumDist: Float64List.fromList(cumDist.sublist(at, at + count)),
            minLat: minLat[i],
            minLon: minLon[i],
            maxLat: maxLat[i],
            maxLon: maxLon[i],
          ),
        );
        at += count;
      }
      if (at != total) throw const _Rejected('pattern table inconsistent');
      return out;
    });

    final routeIndex = r.section(_tagConnections, () {
      final starts = r.uintColumn(patterns.length + 1);
      final total = starts.isEmpty ? 0 : starts.last;
      for (var i = 1; i < starts.length; i++) {
        if (starts[i] < starts[i - 1]) throw const _Rejected('CSR offsets');
      }
      final other = r.uintColumn(total);
      final myIdx = r.uintColumn(total);
      final otherIdx = r.uintColumn(total);
      final walk = r.f32List(total);
      // Every entry must point inside the table it indexes; a corrupted
      // entry that survived the checksum would otherwise crash a query.
      for (var p = 0; p < patterns.length; p++) {
        final stopCount = patterns[p].stopIds.length;
        for (var k = starts[p]; k < starts[p + 1]; k++) {
          final q = other[k];
          if (q < 0 || q >= patterns.length || q == p) {
            throw const _Rejected('connection to an unknown pattern');
          }
          if (myIdx[k] < 0 ||
              myIdx[k] >= stopCount ||
              otherIdx[k] < 0 ||
              otherIdx[k] >= patterns[q].stopIds.length) {
            throw const _Rejected('connection stop position out of range');
          }
        }
      }
      return GtfsRouteIndex.restore(
        data: data,
        patterns: patterns,
        connectionStarts: starts,
        connectionOtherPattern: other,
        connectionMyStopIdx: myIdx,
        connectionOtherStopIdx: otherIdx,
        connectionWalk: walk,
        transferRadiusMeters: transferRadiusMeters,
        sameNameRouteLimit: sameNameRouteLimit,
      );
    });

    final spatialIndex = r.section(_tagSpatial, () {
      final positions = r.uintColumn(stopList.length);
      final seen = Uint8List(stopList.length);
      final preorder = List<GtfsStop>.generate(stopList.length, (i) {
        final p = positions[i];
        if (p < 0 || p >= stopList.length || seen[p] != 0) {
          throw const _Rejected('spatial pre-order is not a permutation');
        }
        seen[p] = 1;
        return stopList[p];
      }, growable: false);
      return GtfsSpatialIndex.restore(stops, preorder);
    });

    final scheduleIndex = r.section(_tagSchedule, () {
      final groups = r.u32();
      final keys = r.uintColumn(groups);
      final counts = r.uintColumn(groups);
      final total = r.u32();
      final order = r.uintColumn(total);
      final byStop = <String, List<GtfsStopTime>>{};
      var at = 0;
      for (var g = 0; g < groups; g++) {
        final count = counts[g];
        if (at + count > total) throw const _Rejected('schedule overflow');
        final list = <GtfsStopTime>[];
        for (var k = 0; k < count; k++) {
          final idx = order[at + k];
          if (idx < 0 || idx >= stopTimes.length) {
            throw const _Rejected('schedule stop time out of range');
          }
          list.add(stopTimes[idx]);
        }
        at += count;
        byStop[pool.required(keys[g])] = list;
      }
      if (at != total || byStop.length != groups) {
        throw const _Rejected('schedule table inconsistent');
      }
      return GtfsScheduleIndex.restore(
        trips: trips,
        stopTimes: stopTimes,
        calendars: calendars,
        calendarDates: calendarDates,
        frequencies: frequencies,
        stopTimesByStop: byStop,
      );
    });

    r.align(8);
    if (r.position != payloadEnd) {
      throw const _Rejected('trailing bytes after the last section');
    }

    return PlannerIndexBundle(
      data: data,
      spatialIndex: spatialIndex,
      routeIndex: routeIndex,
      scheduleIndex: scheduleIndex,
    );
  }

  static Duration? _duration(int seconds) =>
      seconds < 0 ? null : Duration(seconds: seconds);

  static DateTime _dateTime(double microseconds, bool isUtc) {
    if (microseconds.isNaN ||
        microseconds.isInfinite ||
        microseconds != microseconds.truncateToDouble()) {
      throw const _Rejected('date is not a whole number of microseconds');
    }
    return DateTime.fromMicrosecondsSinceEpoch(
      microseconds.toInt(),
      isUtc: isUtc,
    );
  }
}

/// Internal: a validation failure with a reason for the log line.
class _Rejected implements Exception {
  final String reason;

  const _Rejected(this.reason);
}

/// Deduplicated string table; `0` is the null reference, `i + 1` the
/// `i`-th string.
class _StringPool {
  final Map<String, int> _index;
  final List<String> _strings;

  _StringPool() : _index = {}, _strings = [];

  /// Read side: only [optional] / [required] are used.
  _StringPool._restored(this._strings) : _index = const {};

  int ref(String? s) {
    if (s == null) return 0;
    final existing = _index[s];
    if (existing != null) return existing;
    _strings.add(s);
    return _index[s] = _strings.length;
  }

  void write(_Writer w) {
    final encoded = [for (final s in _strings) utf8.encode(s)];
    w.u32(encoded.length);
    var offset = 0;
    final offsets = <int>[];
    for (final e in encoded) {
      offsets.add(offset);
      offset += e.length;
    }
    offsets.add(offset);
    w.uintColumn(offsets);
    for (final e in encoded) {
      w.rawBytes(e);
    }
  }

  static _StringPool read(_Reader r, int tag) {
    return r.section(tag, () {
      final n = r.u32();
      final offsets = r.uintColumn(n + 1);
      final start = r.position;
      final total = offsets.isEmpty ? 0 : offsets.last;
      r.skip(total);
      final strings = List<String>.generate(n, (i) {
        final from = offsets[i];
        final to = offsets[i + 1];
        if (from < 0 || to < from || to > total) {
          throw const _Rejected('string pool offsets');
        }
        return utf8.decoder.convert(r.bytes, start + from, start + to);
      }, growable: false);
      return _StringPool._restored(strings);
    });
  }

  String? optional(int ref) {
    if (ref == 0) return null;
    if (ref < 0 || ref > _strings.length) {
      throw const _Rejected('string reference out of range');
    }
    return _strings[ref - 1];
  }

  String required(int ref) {
    final s = optional(ref);
    if (s == null) throw const _Rejected('missing required string');
    return s;
  }
}

/// Growable little writer over a `Uint8List` with typed-view bulk writes.
class _Writer {
  Uint8List _buf = Uint8List(1 << 16);
  late ByteData _data = ByteData.view(_buf.buffer);
  int _pos = 0;

  int get position => _pos;

  void _ensure(int extra) {
    final needed = _pos + extra;
    if (needed <= _buf.length) return;
    var capacity = _buf.length;
    while (capacity < needed) {
      capacity *= 2;
    }
    final grown = Uint8List(capacity);
    grown.setRange(0, _pos, _buf);
    _buf = grown;
    _data = ByteData.view(grown.buffer);
  }

  void align(int n) {
    final pad = (n - _pos % n) % n;
    _ensure(pad);
    for (var i = 0; i < pad; i++) {
      _buf[_pos++] = 0;
    }
  }

  void u8(int v) {
    _ensure(1);
    _buf[_pos++] = v;
  }

  void u32(int v) {
    _ensure(4);
    _data.setUint32(_pos, v, Endian.host);
    _pos += 4;
  }

  void i32(int v) {
    _ensure(4);
    _data.setInt32(_pos, v, Endian.host);
    _pos += 4;
  }

  void f64(double v) {
    _ensure(8);
    _data.setFloat64(_pos, v, Endian.host);
    _pos += 8;
  }

  void patchU32(int at, int v) => _data.setUint32(at, v, Endian.host);

  void rawBytes(List<int> bytes) {
    _ensure(bytes.length);
    _buf.setRange(_pos, _pos + bytes.length, bytes);
    _pos += bytes.length;
  }

  void string(String s) {
    final encoded = utf8.encode(s);
    u32(encoded.length);
    rawBytes(encoded);
  }

  void u8List(List<int> values) {
    u32(values.length);
    rawBytes(values);
  }

  void f64List(List<double> values) {
    f64Column(values.length, (i) => values[i]);
  }

  /// Float64 column written straight into the buffer (no boxed list of
  /// doubles in between — the shape table alone has 357k points on the
  /// Cochabamba feed).
  void f64Column(int count, double Function(int index) valueAt) {
    u32(count);
    align(8);
    _ensure(count * 8);
    final view = Float64List.view(_buf.buffer, _pos, count);
    for (var i = 0; i < count; i++) {
      view[i] = valueAt(i);
    }
    _pos += count * 8;
  }

  void f32List(Float32List values) {
    u32(values.length);
    align(4);
    _ensure(values.length * 4);
    Float32List.view(_buf.buffer, _pos, values.length).setAll(0, values);
    _pos += values.length * 4;
  }

  /// Non-negative integers with the narrowest width their maximum fits.
  void uintColumn(List<int> values) {
    var max = 0;
    for (final v in values) {
      if (v < 0) {
        throw PlannerIndexEncodeException('negative value $v in uint column');
      }
      if (v > max) max = v;
    }
    if (max > 0xffffffff) {
      throw PlannerIndexEncodeException('value $max does not fit 32 bits');
    }
    final width = max < 0x100 ? 1 : (max < 0x10000 ? 2 : 4);
    u32(values.length);
    u8(width);
    u8(0); // unsigned
    align(width);
    _ensure(values.length * width);
    switch (width) {
      case 1:
        _buf.setRange(_pos, _pos + values.length, values);
      case 2:
        Uint16List.view(_buf.buffer, _pos, values.length).setAll(0, values);
      default:
        Uint32List.view(_buf.buffer, _pos, values.length).setAll(0, values);
    }
    _pos += values.length * width;
  }

  /// Signed 32-bit integers (always 4 bytes; used where `-1` means null).
  void intColumn(List<int> values) {
    u32(values.length);
    u8(4);
    u8(1); // signed
    align(4);
    _ensure(values.length * 4);
    Int32List.view(_buf.buffer, _pos, values.length).setAll(0, values);
    _pos += values.length * 4;
  }

  Uint8List finish({List<int> trailer = const []}) {
    rawBytes(trailer);
    return _buf.sublist(0, _pos);
  }
}

/// Cursor over the blob; every read is bounds-checked against the blob
/// itself (not just the underlying buffer) so truncation surfaces as an
/// exception that [PlannerIndexCodec.decode] turns into `null`.
class _Reader {
  final Uint8List bytes;
  final ByteData _data;
  int _pos = 0;

  _Reader(this.bytes) : _data = ByteData.sublistView(bytes);

  int get position => _pos;

  void _need(int n) {
    if (n < 0 || _pos + n > bytes.length) {
      throw const _Rejected('truncated snapshot');
    }
  }

  void skip(int n) {
    _need(n);
    _pos += n;
  }

  void align(int n) => skip((n - _pos % n) % n);

  int u8() {
    _need(1);
    return bytes[_pos++];
  }

  int u32() {
    _need(4);
    final v = _data.getUint32(_pos, Endian.host);
    _pos += 4;
    return v;
  }

  int i32() {
    _need(4);
    final v = _data.getInt32(_pos, Endian.host);
    _pos += 4;
    return v;
  }

  double f64() {
    _need(8);
    final v = _data.getFloat64(_pos, Endian.host);
    _pos += 8;
    return v;
  }

  String string() {
    final n = u32();
    _need(n);
    final s = utf8.decoder.convert(bytes, _pos, _pos + n);
    _pos += n;
    return s;
  }

  T section<T>(int tag, T Function() body) {
    align(8);
    final actual = u32();
    if (actual != tag) throw _Rejected('expected section $tag, found $actual');
    final length = u32();
    final start = _pos;
    _need(length);
    final result = body();
    if (_pos - start != length) {
      throw _Rejected('section $tag length mismatch');
    }
    align(8);
    return result;
  }

  int _count(int expected) {
    final n = u32();
    if (n != expected) throw const _Rejected('column length mismatch');
    return n;
  }

  Uint8List u8List(int expected) {
    final n = _count(expected);
    _need(n);
    final view = Uint8List.sublistView(bytes, _pos, _pos + n);
    _pos += n;
    return view;
  }

  /// A copy, so the blob's buffer is not kept alive by the restored index.
  Float64List f64List(int expected) {
    final n = _count(expected);
    align(8);
    _need(n * 8);
    final view = Float64List.view(bytes.buffer, bytes.offsetInBytes + _pos, n);
    _pos += n * 8;
    return Float64List.fromList(view);
  }

  Float32List f32List(int expected) {
    final n = _count(expected);
    align(4);
    _need(n * 4);
    final view = Float32List.view(bytes.buffer, bytes.offsetInBytes + _pos, n);
    _pos += n * 4;
    return Float32List.fromList(view);
  }

  /// Widens a stored column (any width, signed or not) to an `Int32List`.
  Int32List _column(int expected) {
    final n = _count(expected);
    final width = u8();
    final signed = u8() != 0;
    if (width != 1 && width != 2 && width != 4) {
      throw const _Rejected('column width');
    }
    align(width);
    _need(n * width);
    final base = bytes.offsetInBytes + _pos;
    final out = Int32List(n);
    switch (width) {
      case 1:
        out.setAll(0, Uint8List.view(bytes.buffer, base, n));
      case 2:
        out.setAll(0, Uint16List.view(bytes.buffer, base, n));
      default:
        if (signed) {
          out.setAll(0, Int32List.view(bytes.buffer, base, n));
        } else {
          final view = Uint32List.view(bytes.buffer, base, n);
          for (var i = 0; i < n; i++) {
            final v = view[i];
            if (v > 0x7fffffff) throw const _Rejected('value beyond int32');
            out[i] = v;
          }
        }
    }
    _pos += n * width;
    return out;
  }

  Int32List uintColumn(int expected) => _column(expected);

  Int32List intColumn(int expected) => _column(expected);
}

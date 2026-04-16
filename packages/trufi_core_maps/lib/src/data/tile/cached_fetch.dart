import 'dart:typed_data';
import 'package:dio/dio.dart';

/// Shared configuration for the tile fetcher.
///
/// Set [deviceIdProvider] once at app startup to include the `X-Device-Id`
/// header on every tile request.
class CachedFetchConfig {
  CachedFetchConfig._();

  static Future<String?> Function()? deviceIdProvider;
}

final Dio _dio = Dio();
final Map<String, CancelToken> _activeRequests = {};

int? _lastZ, _lastX, _lastY;

Future<Uint8List> cachedFirstFetch(Uri uri, int z, int x, int y) async {
  final key = uri.toString();

  if (_lastZ != null) {
    final zoomChanged = z != _lastZ;
    final movedFar = (x - _lastX!).abs() > 2 || (y - _lastY!).abs() > 2;
    if (zoomChanged || movedFar) {
      _cancelFarTiles(z, x, y);
    }
  }

  _lastZ = z;
  _lastX = x;
  _lastY = y;

  final cancelToken = CancelToken();
  _activeRequests[key] = cancelToken;

  final headers = <String, dynamic>{};
  final provider = CachedFetchConfig.deviceIdProvider;
  if (provider != null) {
    final deviceId = await provider();
    if (deviceId != null && deviceId.isNotEmpty) {
      headers['X-Device-Id'] = deviceId;
    }
  }

  try {
    final response = await _dio.get<List<int>>(
      key,
      options: Options(
        responseType: ResponseType.bytes,
        headers: headers.isEmpty ? null : headers,
      ),
      cancelToken: cancelToken,
    );

    final data = response.data;
    if (data == null) {
      throw Exception("Empty response for $key");
    }
    return Uint8List.fromList(data);
  } on DioException catch (e) {
    if (CancelToken.isCancel(e)) {
      throw Exception("Request to $key was cancelled.");
    } else {
      throw Exception("Fetch failed for $key: ${e.message}");
    }
  } finally {
    _activeRequests.remove(key);
  }
}

void _cancelFarTiles(int z, int x, int y) {
  for (final entry in _activeRequests.entries.toList()) {
    final key = entry.key;
    final token = entry.value;

    final uri = Uri.tryParse(key);
    if (uri == null) continue;

    final parts = uri.pathSegments;
    if (parts.length < 3) continue;

    final uz = int.tryParse(parts[parts.length - 3]);
    final ux = int.tryParse(parts[parts.length - 2]);
    final uy = int.tryParse(parts[parts.length - 1].split('.').first);

    if (uz == null || ux == null || uy == null) continue;

    final zoomChanged = uz != z;
    final movedFar = (ux - x).abs() > 2 || (uy - y).abs() > 2;

    if ((zoomChanged || movedFar) && !token.isCancelled) {
      token.cancel("Tile $key out of focus or zoom");
    }
  }
}

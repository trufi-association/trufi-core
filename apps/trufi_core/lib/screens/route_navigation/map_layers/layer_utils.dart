abstract class LayerUtils {
  static String templateTileUrl(String layerUrl, int x, int y, int z) {
    final Map<String, String> data = {
      'x': x.toString(),
      'y': y.toString(),
      'z': z.toString(),
      '-y': ((1 << z) - (1 + y)).toString(),
    };

    return layerUrl.replaceAllMapped(RegExp(r'\{ *([-\w]+) *\}'), (match) {
      final key = match.group(1);
      if (key == null || !data.containsKey(key)) {
        throw ArgumentError('No value provided for variable {$key}');
      }
      return data[key]!;
    });
  }

  static List<int> extractZXY(String uriString) {
    final parts = uriString.split('/');
    final cleanParts = parts.where((e) => e.isNotEmpty).toList();

    final yWithExtension = cleanParts[cleanParts.length - 1];
    
    final newZ = int.parse(cleanParts[cleanParts.length - 3]);
    final newX = int.parse(cleanParts[cleanParts.length - 2]);
    final newY = int.parse(yWithExtension.split('.').first);

    return [newZ, newX, newY];
  }
}

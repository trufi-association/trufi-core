/// Simple CSV parser for GTFS files.
class CsvParser {
  /// Parse CSV content into a list of maps.
  /// Each map represents a row with column names as keys.
  static List<Map<String, String>> parse(String content) {
    final lines = content.split('\n');
    if (lines.isEmpty) return [];

    // Parse header row
    final headers = _parseLine(lines.first);
    if (headers.isEmpty) return [];

    // Parse data rows
    final rows = <Map<String, String>>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = _parseLine(line);
      if (values.isEmpty) continue;

      // Pad values if needed (some files have optional trailing columns)
      final paddedValues = List<String>.from(values);
      while (paddedValues.length < headers.length) {
        paddedValues.add('');
      }

      final row = <String, String>{};
      for (var j = 0; j < headers.length && j < paddedValues.length; j++) {
        row[headers[j]] = paddedValues[j];
      }
      rows.add(row);
    }

    return rows;
  }

  /// Parse a single CSV line, handling quoted fields.
  static List<String> _parseLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        // Check for escaped quote
        if (i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++; // Skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        values.add(buffer.toString().trim());
        buffer.clear();
      } else if (char != '\r') {
        // Skip carriage return
        buffer.write(char);
      }
    }

    // Add last value
    values.add(buffer.toString().trim());

    return values;
  }
}

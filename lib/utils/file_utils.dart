import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class FileUtils {
  Future<String> readFile(String path) async {
    return await rootBundle.loadString(path);
  }
}

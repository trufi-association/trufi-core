import 'dart:io';

import 'package:trufi_app/location/location_storage.dart';
import 'package:trufi_app/trufi_models.dart';

class History extends LocationStorage {
  static History _instance;

  static History get instance => _instance;

  static void init() async {
    File file = await localFile("location_search_history.json");
    _instance ??= History._init(file, await readStorage(file));
  }

  History._init(File file, List<TrufiLocation> locations)
      : super(file, locations);

  factory History() => _instance;
}

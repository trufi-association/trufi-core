import 'dart:io';

import 'package:trufi_app/location/location_storage.dart';
import 'package:trufi_app/trufi_models.dart';

class Favorites extends LocationStorage {
  static Favorites _instance;

  static Favorites get instance => _instance;

  static void init() async {
    File file = await localFile("location_search_favorites.json");
    _instance ??= Favorites._init(file, await readStorage(file));
  }

  Favorites._init(File file, List<TrufiLocation> locations)
      : super(file, locations);

  factory Favorites() => _instance;
}

int sortByFavorite(TrufiLocation a, TrufiLocation b) {
  bool aIsFavorite = Favorites.instance.contains(a);
  bool bIsFavorite = Favorites.instance.contains(b);
  return aIsFavorite == bIsFavorite ? 0 : aIsFavorite ? -1 : 1;
}
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:hive/hive.dart' show Hive;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

import 'package:graphql/client.dart' show HiveStore;
import 'package:trufi_core/base/blocs/localization/trufi_localization_cubit.dart';
import 'package:trufi_core/base/blocs/map_tile_provider/map_tile_local_storage.dart';
import 'package:trufi_core/base/blocs/providers/app_review_provider.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
import 'package:trufi_core/base/pages/home/repository/hive_local_repository.dart';
import 'package:trufi_core/base/pages/saved_places/repository/local_repository/hive_local_repository.dart';
import 'package:trufi_core/base/pages/transport_list/repository/hive_local_repository.dart';

/// Initializes Hive with the path from [getApplicationDocumentsDirectory].
///
/// You can provide a [subDir] where the boxes should be stored.
///
/// Extracted from [`hive_flutter` source][github]
///
/// [github]: https://github.com/hivedb/hive/blob/5bf355496650017409fef4e9905e8826c5dc5bf3/hive_flutter/lib/src/hive_extensions.dart
Future<void> initHiveForFlutter({
  String? subDir,
  List<String> boxes = listPathsHive,
}) async {
  if (!kIsWeb) {
    var appDir = await getApplicationDocumentsDirectory();
    var path = appDir.path;
    if (subDir != null) {
      path = join(path, subDir);
    }
    Hive.init(path);
  }

  for (var box in boxes) {
    await Hive.openBox(box);
  }
}

const listPathsHive = [
  HiveStore.defaultBoxName,
  AppReviewProviderHiveLocalRepository.path,
  TrufiLocalizationHiveLocalRepository.path,
  TrufiBaseThemeHiveLocalRepository.path,
  MapRouteHiveLocalRepository.path,
  SearchLocationsHiveLocalRepository.path,
  RouteTransportsHiveLocalRepository.path,
  MapTileLocalStorage.customLayersStorage,
];

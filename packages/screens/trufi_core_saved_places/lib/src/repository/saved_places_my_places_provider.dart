import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import 'saved_places_repository.dart';

/// Adapter that wraps a [SavedPlacesRepository] and implements [MyPlacesProvider].
///
/// This allows using saved_places with search_locations package.
///
/// Example:
/// ```dart
/// final repository = HiveSavedPlacesRepository();
/// await repository.initialize();
///
/// final provider = SavedPlacesMyPlacesProvider(repository);
///
/// // Use with LocationSearchScreen
/// LocationSearchScreen(
///   myPlacesProvider: provider,
///   // ...
/// )
/// ```
class SavedPlacesMyPlacesProvider implements MyPlacesProvider {
  final SavedPlacesRepository _repository;

  SavedPlacesMyPlacesProvider(this._repository);

  @override
  Future<MyPlace?> getHome() async {
    final home = await _repository.getHome();
    return home?.toMyPlace();
  }

  @override
  Future<MyPlace?> getWork() async {
    final work = await _repository.getWork();
    return work?.toMyPlace();
  }

  @override
  Future<List<MyPlace>> getOtherPlaces() async {
    final places = await _repository.getOtherPlaces();
    return places.map((p) => p.toMyPlace()).toList();
  }

  @override
  Future<List<MyPlace>> getMyPlaces() async {
    final places = <MyPlace>[];

    final home = await getHome();
    if (home != null) places.add(home);

    final work = await getWork();
    if (work != null) places.add(work);

    final otherPlaces = await getOtherPlaces();
    places.addAll(otherPlaces);

    return places;
  }
}

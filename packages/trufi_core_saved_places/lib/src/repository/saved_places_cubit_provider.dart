import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../cubit/saved_places_cubit.dart';

/// A [MyPlacesProvider] that reads places from a [SavedPlacesCubit].
///
/// This provider reads directly from the cubit's current state,
/// so it always returns the most up-to-date places without needing
/// to query the repository.
///
/// Usage with search_locations:
/// ```dart
/// // Get the cubit from context
/// final cubit = context.read<SavedPlacesCubit>();
/// final provider = SavedPlacesCubitProvider(cubit);
///
/// // Use with LocationSearchScreen
/// LocationSearchScreen(
///   myPlacesProvider: provider,
///   // ...
/// )
/// ```
class SavedPlacesCubitProvider implements MyPlacesProvider {
  final SavedPlacesCubit _cubit;

  SavedPlacesCubitProvider(this._cubit);

  @override
  Future<MyPlace?> getHome() async {
    return _cubit.state.home?.toMyPlace();
  }

  @override
  Future<MyPlace?> getWork() async {
    return _cubit.state.work?.toMyPlace();
  }

  @override
  Future<List<MyPlace>> getOtherPlaces() async {
    return _cubit.state.otherPlaces.map((p) => p.toMyPlace()).toList();
  }

  @override
  Future<List<MyPlace>> getMyPlaces() async {
    final places = <MyPlace>[];

    final home = _cubit.state.home;
    if (home != null) places.add(home.toMyPlace());

    final work = _cubit.state.work;
    if (work != null) places.add(work.toMyPlace());

    for (final place in _cubit.state.otherPlaces) {
      places.add(place.toMyPlace());
    }

    return places;
  }
}

part of 'saved_places_cubit.dart';

/// Status of saved places operations.
enum SavedPlacesStatus {
  initial,
  loading,
  loaded,
  error,
}

/// State for the SavedPlacesCubit.
class SavedPlacesState extends Equatable {
  final SavedPlacesStatus status;
  final SavedPlace? home;
  final SavedPlace? work;
  final List<SavedPlace> otherPlaces;
  final List<SavedPlace> history;
  final String? errorMessage;

  const SavedPlacesState({
    this.status = SavedPlacesStatus.initial,
    this.home,
    this.work,
    this.otherPlaces = const [],
    this.history = const [],
    this.errorMessage,
  });

  /// Returns all saved places (excluding history).
  List<SavedPlace> get allPlaces {
    final List<SavedPlace> places = [];
    if (home != null) places.add(home!);
    if (work != null) places.add(work!);
    places.addAll(otherPlaces);
    return places;
  }

  /// Returns default places (home and work).
  List<SavedPlace?> get defaultPlaces => [home, work];

  /// Returns history in reverse chronological order.
  List<SavedPlace> get recentHistory => history.toList();

  SavedPlacesState copyWith({
    SavedPlacesStatus? status,
    SavedPlace? home,
    SavedPlace? work,
    List<SavedPlace>? otherPlaces,
    List<SavedPlace>? history,
    String? errorMessage,
    bool clearHome = false,
    bool clearWork = false,
  }) {
    return SavedPlacesState(
      status: status ?? this.status,
      home: clearHome ? null : (home ?? this.home),
      work: clearWork ? null : (work ?? this.work),
      otherPlaces: otherPlaces ?? this.otherPlaces,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        home,
        work,
        otherPlaces,
        history,
        errorMessage,
      ];
}

part of 'search_locations_cubit.dart';

class SearchLocationsState extends Equatable {
  final List<TrufiLocation> myPlaces;
  final List<TrufiLocation> myDefaultPlaces;
  final List<TrufiLocation> historyPlaces;
  final List<TrufiLocation> favoritePlaces;
  final List<TrufiPlace> searchResult;
  final bool isLoading;

  const SearchLocationsState({
    this.myPlaces = const [],
    this.myDefaultPlaces = const [],
    this.historyPlaces = const [],
    this.favoritePlaces = const [],
    this.searchResult = const [],
    this.isLoading = false,
  });

  SearchLocationsState copyWith({
    List<TrufiLocation>? myPlaces,
    List<TrufiLocation>? myDefaultPlaces,
    List<TrufiLocation>? historyPlaces,
    List<TrufiLocation>? favoritePlaces,
    List<TrufiPlace>? searchResult,
    bool? isLoading,
  }) {
    return SearchLocationsState(
      myPlaces: myPlaces ?? this.myPlaces,
      myDefaultPlaces: myDefaultPlaces ?? this.myDefaultPlaces,
      historyPlaces: historyPlaces ?? this.historyPlaces,
      favoritePlaces: favoritePlaces ?? this.favoritePlaces,
      searchResult: searchResult ?? this.searchResult,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [
        myPlaces,
        myDefaultPlaces,
        historyPlaces,
        favoritePlaces,
        searchResult,
        isLoading
      ];
}

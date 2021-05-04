part of 'saved_places_locations_cubit.dart';

class SavedPlacesLocationsState extends Equatable {
  final List<TrufiLocation> locations;
  const SavedPlacesLocationsState({
    @required this.locations,
  });

  SavedPlacesLocationsState copyWith({
    List<TrufiLocation> locations,
  }) {
    return SavedPlacesLocationsState(
      locations: locations ?? this.locations,
    );
  }

  @override
  List<Object> get props => [locations];

}

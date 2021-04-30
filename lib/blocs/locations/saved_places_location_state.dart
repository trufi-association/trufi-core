
part of 'saved_places_locations_cubit.dart';
class SavedPlacesLocationState extends Equatable {
  final List<TrufiLocation> locations;
  const SavedPlacesLocationState({
    @required this.locations,
  });

  SavedPlacesLocationState copyWith({
    List<TrufiLocation> locations,
  }) {
    return SavedPlacesLocationState(
      locations: locations ?? this.locations,
    );
  }

  @override
  List<Object> get props => [locations];

}

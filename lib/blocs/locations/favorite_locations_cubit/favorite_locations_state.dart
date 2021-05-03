part of 'favorite_locations_cubit.dart';

class FavoriteLocationsState extends Equatable {
  final List<TrufiLocation> locations;
  const FavoriteLocationsState({
    @required this.locations,
  });

  FavoriteLocationsState copyWith({
    List<TrufiLocation> locations,
  }) {
    return FavoriteLocationsState(
      locations: locations ?? this.locations,
    );
  }

  @override
  List<Object> get props => [locations];

}
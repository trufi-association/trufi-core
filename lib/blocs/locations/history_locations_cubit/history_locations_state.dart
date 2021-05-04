part of 'history_locations_cubit.dart';

class HistoryLocationsState extends Equatable {
  final List<TrufiLocation> locations;
  const HistoryLocationsState({
    @required this.locations,
  });

  HistoryLocationsState copyWith({
    List<TrufiLocation> locations,
  }) {
    return HistoryLocationsState(
      locations: locations ?? this.locations,
    );
  }

  @override
  List<Object> get props => [locations];

}
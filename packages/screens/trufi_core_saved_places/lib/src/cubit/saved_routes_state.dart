part of 'saved_routes_cubit.dart';

/// State for the [SavedRoutesCubit].
class SavedRoutesState extends Equatable {
  final List<SavedRoute> routes;
  final bool isLoading;
  final String? error;

  const SavedRoutesState({
    this.routes = const [],
    this.isLoading = false,
    this.error,
  });

  SavedRoutesState copyWith({
    List<SavedRoute>? routes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SavedRoutesState(
      routes: routes ?? this.routes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [routes, isLoading, error];
}

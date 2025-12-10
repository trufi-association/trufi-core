import 'package:flutter/material.dart';

import 'models/transport_route.dart';

/// State for transport list data
class TransportListState {
  final List<TransportRoute> routes;
  final List<TransportRoute> filteredRoutes;
  final bool isLoading;
  final bool isLoadingDetails;

  const TransportListState({
    this.routes = const [],
    this.filteredRoutes = const [],
    this.isLoading = false,
    this.isLoadingDetails = false,
  });

  TransportListState copyWith({
    List<TransportRoute>? routes,
    List<TransportRoute>? filteredRoutes,
    bool? isLoading,
    bool? isLoadingDetails,
  }) {
    return TransportListState(
      routes: routes ?? this.routes,
      filteredRoutes: filteredRoutes ?? this.filteredRoutes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
    );
  }
}

/// Provider interface for transport list data
abstract class TransportListDataProvider extends ChangeNotifier {
  TransportListState get state;

  /// Load initial routes
  Future<void> load();

  /// Refresh routes from server
  Future<void> refresh();

  /// Filter routes by query
  void filter(String query);

  /// Get route details by code
  Future<TransportRouteDetails?> getRouteDetails(String code);
}

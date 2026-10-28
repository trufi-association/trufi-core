import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:trufi_core/base/models/transit_route/transit_route.dart';

import '../repository/hive_local_repository.dart';
import '../repository/local_repository.dart';
import '../services/route_transports_service.dart';

part 'route_transports_state.dart';

class RouteTransportsCubit extends Cubit<RouteTransportsState> {
  final RouteTransportsLocalRepository localRepository;
  final RouteTransportsRemoteRepository routeTransportsRepository;

  /// The fetch in flight, shared by a background refresh and a refresh the
  /// user asks for meanwhile: one request, each caller keeps its semantics.
  Future<List<TransitRoute>>? _inFlight;

  /// The query the list is filtered with, reapplied when the list changes.
  String _query = '';

  RouteTransportsCubit(
    String otpEndpoint, {
    RouteTransportsLocalRepository? localRepository,
    RouteTransportsRemoteRepository? routeTransportsRepository,
  })  : localRepository =
            localRepository ?? RouteTransportsHiveLocalRepository(),
        routeTransportsRepository =
            routeTransportsRepository ?? RouteTransportsServices(otpEndpoint),
        super(const RouteTransportsState()) {
    load().catchError((error) {});
  }

  /// Shows the cached list at once and, when there is one, fetches the feed
  /// again in the background so a server update reaches installed apps
  /// without the refresh button (trufi-arequipa#74). Offline or on error the
  /// cached list simply stays.
  Future<void> load() async {
    if (state.transports.isNotEmpty) return;
    await localRepository.loadRepository();
    final cached = await localRepository.getTransports();
    emit(state.copyWith(transports: cached, filterTransports: cached));
    if (cached.isEmpty) {
      await refresh();
      return;
    }
    await refresh(silent: true);
  }

  /// Fetches the patterns from the server. With [silent] the loading overlay
  /// is not shown and a failure is swallowed (the current list is kept).
  /// A list equal to the one shown changes nothing: no emit, no cache write
  /// (the Hive box is append-only, a frame per write).
  Future<void> refresh({bool silent = false}) async {
    if (!silent) emit(state.copyWith(isLoading: true));
    try {
      // Sorted once, inside the shared future: two awaiters get the same
      // list, and List.sort is not stable (the two directions of a route
      // tie), so sorting per caller could reorder a list already emitted.
      final fetch =
          _inFlight ??= routeTransportsRepository.fetchPatterns().then((list) {
        sortTransitRoutesByAgencyNameAndShortName(list);
        return list;
      }).whenComplete(() => _inFlight = null);
      final transports = await fetch;
      if (listEquals(transports, state.transports)) {
        if (!silent) emit(state.copyWith(isLoading: false));
        return;
      }
      emit(state.copyWith(
        transports: transports,
        filterTransports: _filtered(transports, _query),
        isLoading: false,
      ));
      await localRepository.saveTransports(transports);
    } catch (e) {
      if (silent) {
        debugPrint('RouteTransportsCubit: background refresh failed: $e');
        return;
      }
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  void sortTransitRoutesByAgencyNameAndShortName(List<TransitRoute> routes) {
    routes.sort((a, b) {
      final nameA = a.route?.agency?.name.toLowerCase() ?? '';
      final nameB = b.route?.agency?.name.toLowerCase() ?? '';
      final shortNameA = a.route?.shortName?.toLowerCase() ?? '';
      final shortNameB = b.route?.shortName?.toLowerCase() ?? '';

      // First compare by Agency name
      final agencyNameComparison = nameA.compareTo(nameB);
      if (agencyNameComparison != 0) {
        return agencyNameComparison;
      }

      // If Agency names are the same, compare by shortName
      return shortNameA.compareTo(shortNameB);
    });
  }

  Future<TransitRoute> fetchDataPattern(TransitRoute pattern) async {
    if (pattern.geometry != null) return pattern;
    emit(state.copyWith(isGeometryLoading: true));
    final newPattern =
        await routeTransportsRepository.fetchDataPattern(pattern.code);
    final newPatterns = _updateItem(state.transports, pattern, newPattern);
    emit(
      state.copyWith(
        transports: newPatterns,
        filterTransports: _filtered(newPatterns, _query),
        isGeometryLoading: false,
      ),
    );
    await localRepository.saveTransports(newPatterns);
    return pattern.copyWith(
      geometry: newPattern.geometry,
      stops: newPattern.stops,
    );
  }

  List<TransitRoute> _updateItem(
    List<TransitRoute> list,
    TransitRoute oldLocation,
    TransitRoute newLocation,
  ) {
    final tempList = [...list];
    final int index = tempList.indexOf(oldLocation);
    if (index != -1) {
      tempList.replaceRange(index, index + 1, [
        oldLocation.copyWith(
          geometry: newLocation.geometry,
          stops: newLocation.stops,
        )
      ]);
    }
    return tempList;
  }

  /// Filters the list by [query], case- and accent-insensitively, against
  /// the route code, its long name and its operator (trufi-core#1039: "C9"
  /// and "Emarsistran" found nothing because only the lowercased code and
  /// long name were searched, and only when the caller lowercased the
  /// query; "union" found none of the 50 "Unión" patterns).
  void filterTransports(String query) {
    _query = _fold(query);
    emit(state.copyWith(filterTransports: _filtered(state.transports, _query)));
  }

  List<TransitRoute> _filtered(List<TransitRoute> transports, String query) {
    if (query.isEmpty) return transports;
    return transports.where((element) {
      final route = element.route;
      final haystack = _fold(
        '${element.name} ${route?.longNameData ?? ''} ${route?.agency?.name ?? ''}',
      );
      return haystack.contains(query);
    }).toList();
  }

  /// Lowercase, trimmed, without the accents the feed's names carry.
  static String _fold(String text) {
    var out = text.trim().toLowerCase();
    const accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n'};
    accents.forEach((from, to) => out = out.replaceAll(from, to));
    return out;
  }
}

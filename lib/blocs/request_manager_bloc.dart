import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized/synchronized.dart';
import 'package:trufi_core/blocs/favorite_locations_bloc.dart';
import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/repository/request_manager.dart';
import 'package:trufi_core/trufi_models.dart';

class RequestManagerBloc extends Cubit<void> implements RequestManager {
  final RequestManager _offlineRequestManager;
  final RequestManager _onlineRequestManager;
  final _fetchLocationLock = Lock();

  RequestManagerBloc(this._offlineRequestManager, this._onlineRequestManager)
      : super(null);

  CancelableOperation<List<TrufiPlace>> _fetchLocationOperation;

  @override
  Future<List<TrufiPlace>> fetchLocations(
    FavoriteLocationsBloc favoriteLocationsBloc,
    LocationSearchBloc locationSearchBloc,
    String query, {
    String correlationId,
    int limit = 30,
  }) {
    // Cancel running operation
    if (_fetchLocationOperation != null) {
      _fetchLocationOperation.cancel();
      _fetchLocationOperation = null;
    }

    // Allow only one running request
    return (_fetchLocationLock.locked)
        ? Future.value()
        : _fetchLocationLock.synchronized(() async {
            _fetchLocationOperation =
                CancelableOperation<List<TrufiPlace>>.fromFuture(
              // FIXME: For now we search locations always offline
              _offlineRequestManager.fetchLocations(
                  favoriteLocationsBloc, locationSearchBloc, query,
                  limit: limit, correlationId: correlationId),
            );
            return _fetchLocationOperation.valueOrCancellation(null);
          });
  }

  @override
  CancelableOperation<Plan> fetchTransitPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    // FIXME: For now we fetch plans always online
    // _requestManager.fetchPlan(context, from, to);
    return _onlineRequestManager.fetchTransitPlan(context, from, to);
  }

  @override
  CancelableOperation<Plan> fetchCarPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    return _onlineRequestManager.fetchCarPlan(context, from, to);
  }

  @override
  CancelableOperation<Ad> fetchAd(
    BuildContext context,
    TrufiLocation to,
  ) {
    return _onlineRequestManager.fetchAd(context, to);
  }
}

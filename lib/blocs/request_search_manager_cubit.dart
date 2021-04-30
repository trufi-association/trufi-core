import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized/synchronized.dart';
import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/blocs/locations/favorite_locations_cubit/favorite_locations_cubit.dart';
import 'package:trufi_core/repository/request_manager.dart';
import 'package:trufi_core/trufi_models.dart';

// TODO: This is actually not a Cubit it is just a service / controller
//  there is no state that it contains
class RequestSearchManagerCubit extends Cubit<void> {
  final RequestManager _offlineRequestManager;
  final _fetchLocationLock = Lock();

  RequestSearchManagerCubit(this._offlineRequestManager) : super(null);

  CancelableOperation<List<TrufiPlace>> _fetchLocationOperation;

  Future<List<TrufiPlace>> fetchLocations(
    FavoriteLocationsCubit favoriteLocationsCubit,
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
                  favoriteLocationsCubit, locationSearchBloc, query,
                  limit: limit, correlationId: correlationId),
            );
            return _fetchLocationOperation.valueOrCancellation(null);
          });
  }
}

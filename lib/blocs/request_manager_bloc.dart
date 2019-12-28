import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

import '../blocs/bloc_provider.dart';
import '../blocs/preferences_bloc.dart';
import '../blocs/request_manager/offline_request_manager.dart';
import '../blocs/request_manager/online_request_manager.dart';
import '../composite_subscription.dart';
import '../trufi_models.dart';

class RequestManagerBloc implements BlocBase, RequestManager {
  static RequestManagerBloc of(BuildContext context) {
    return BlocProvider.of<RequestManagerBloc>(context);
  }

  RequestManagerBloc(this.preferencesBloc) {
    _requestManager = _onlineRequestManager;
    _subscriptions.add(
      preferencesBloc.outChangeOnline.listen((online) {
        _requestManager =
            online ? _onlineRequestManager : _offlineRequestManager;
      }),
    );
  }

  final PreferencesBloc preferencesBloc;

  final _subscriptions = CompositeSubscription();
  final _offlineRequestManager = OfflineRequestManager();
  final _onlineRequestManager = OnlineRequestManager();
  final _fetchLocationLock = Lock();

  CancelableOperation<List<dynamic>> _fetchLocationOperation;
  RequestManager _requestManager;

  // Dispose

  @override
  void dispose() {
    _subscriptions.cancel();
  }

  // Methods

  Future<List<dynamic>> fetchLocations(
    BuildContext context,
    String query,
    int limit,
  ) {
    // Cancel running operation
    if (_fetchLocationOperation != null) {
      _fetchLocationOperation.cancel();
      _fetchLocationOperation = null;
    }

    // Allow only one running request
    return (_fetchLocationLock.locked)
        ? Future.value(null)
        : _fetchLocationLock.synchronized(() async {
            _fetchLocationOperation = CancelableOperation.fromFuture(
              Future.delayed(
                Duration.zero,
                () {
                  // FIXME: For now we search locations always offline
                  return _offlineRequestManager.fetchLocations(
                    context,
                    query,
                    limit,
                  );
                },
              ),
            );
            return _fetchLocationOperation.valueOrCancellation(null);
          });
  }

  CancelableOperation<Plan> fetchTransitPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    // FIXME: For now we fetch plans always online
    // _requestManager.fetchPlan(context, from, to);
    return _onlineRequestManager.fetchTransitPlan(context, from, to);
  }

  CancelableOperation<Plan> fetchCarPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    return _onlineRequestManager.fetchCarPlan(context, from, to);
  }

  CancelableOperation<Ad> fetchAd(
    BuildContext context,
    TrufiLocation to,
  ) {
    return _onlineRequestManager.fetchAd(context, to);
  }
}

// RequestManager

abstract class RequestManager {
  Future<List<dynamic>> fetchLocations(
    BuildContext context,
    String query,
    int limit,
  );

  CancelableOperation<Plan> fetchTransitPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  );

  CancelableOperation<Plan> fetchCarPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  );

  CancelableOperation<Ad> fetchAd(
    BuildContext context,
    TrufiLocation to,
  );
}

// Exceptions

class FetchOfflineRequestException implements Exception {
  FetchOfflineRequestException(this._innerException);

  final Exception _innerException;

  String toString() {
    return "Fetch offline request exception caused by: ${_innerException.toString()}";
  }
}

class FetchOfflineResponseException implements Exception {
  FetchOfflineResponseException(this._message);

  final String _message;

  @override
  String toString() {
    return "Fetch offline response exception: $_message";
  }
}

class FetchOnlineRequestException implements Exception {
  FetchOnlineRequestException(this._innerException);

  final Exception _innerException;

  String toString() {
    return "Fetch online request exception caused by: ${_innerException.toString()}";
  }
}

class FetchOnlineResponseException implements Exception {
  FetchOnlineResponseException(this._message);

  final String _message;

  @override
  String toString() {
    return "Fetch online response exception: $_message";
  }
}

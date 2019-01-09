import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/blocs/request_manager/offline_request_manager.dart';
import 'package:trufi_app/blocs/request_manager/online_request_manager.dart';
import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/trufi_models.dart';

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

  CancelableOperation<List<TrufiLocation>> _fetchLocationOperation;
  RequestManager _requestManager;

  // Dispose

  @override
  void dispose() {
    _subscriptions.cancel();
  }

  // Methods

  Future<List<TrufiLocation>> fetchLocations(
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
                  // FIXME: For now we search locations always online
                  return _onlineRequestManager.fetchLocations(
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

  Future<Plan> fetchPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    // FIXME: For now we fetch plans always online
    //return _requestManager.fetchPlan(context, from, to);
    return _onlineRequestManager.fetchPlan(context, from, to);
  }

  FetchPlanOperation fetchPlanCancelable(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    return FetchPlanOperation(
      // FIXME: For now we fetch plans always online
      // _requestManager.fetchPlan(context, from, to);
      _onlineRequestManager.fetchPlan(context, from, to),
    );
  }
}

// RequestManager

abstract class RequestManager {
  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
    int limit,
  );

  Future<Plan> fetchPlan(
    BuildContext context,
    TrufiLocation from,
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

class FetchPlanOperation {
  FetchPlanOperation(Future<Plan> fetch) {
    _cancelableOperation = CancelableOperation.fromFuture(fetch);
  }

  CancelableOperation<Plan> _cancelableOperation;

  Future<Plan> fetch() {
    return _cancelableOperation.valueOrCancellation(null);
  }

  void cancel() {
    _cancelableOperation.cancel();
  }
}

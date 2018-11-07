import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:synchronized/synchronized.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/offline_locations_bloc.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';

class RequestManagerBloc implements BlocBase, RequestManager {
  static RequestManagerBloc of(BuildContext context) {
    return BlocProvider.of<RequestManagerBloc>(context);
  }

  RequestManagerBloc(this.preferencesBloc) {
    _requestManager = _offlineRequestManager;
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
  final _lock = Lock();

  CancelableOperation<List<TrufiLocation>> _operation;
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
  ) {
    if (_operation != null) {
      _operation.cancel();
    }

    if (!_lock.locked) {
      return _lock.synchronized(() async {
        _operation = CancelableOperation.fromFuture(Future.delayed(
            Duration(seconds: 1),
            () => _requestManager.fetchLocations(context, query)));
        return _operation.valueOrCancellation(null);
      });
    }
    return Future.value(null);
  }

  Future<Plan> fetchPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    return _requestManager.fetchPlan(context, from, to);
  }
}

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

abstract class RequestManager {
  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
  );

  Future<Plan> fetchPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  );
}

class OfflineRequestManager implements RequestManager {
  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
  ) async {
    List<TrufiLocation> locations =
        await OfflineLocationsBloc.of(context).fetchWithQuery(context, query);
    locations.sort((a, b) {
      return sortByImportance(a, b);
    });
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    locations.sort((a, b) {
      return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
    });
    return locations;
  }

  Future<Plan> fetchPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) async {
    throw FetchOfflineRequestException(
      Exception("Fetch plan offline is not implemented yet."),
    );
  }
}

class OnlineRequestManager implements RequestManager {
  static const String Endpoint = 'trufiapp.westeurope.cloudapp.azure.com';
  static const String PlanPath = 'otp/routers/default/plan';

  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
  ) async {
    List<TrufiLocation> locations =
        await OfflineLocationsBloc.of(context).fetchWithQuery(context, query);
    locations.sort((a, b) {
      return sortByImportance(a, b);
    });
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    locations.sort((a, b) {
      return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
    });
    return locations;
  }

  Future<Plan> fetchPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) async {
    Uri request = Uri.https(Endpoint, PlanPath, {
      "fromPlace": from.toString(),
      "toPlace": to.toString(),
      "date": "01-01-2018",
      "mode": "TRANSIT,WALK"
    });
    final response = await _fetchRequest(request);
    if (response.statusCode == 200) {
      Plan plan = await compute(_parsePlan, utf8.decode(response.bodyBytes));
      if (plan.hasError) {
        plan = Plan.fromError(
          _localizedErrorForPlanError(
            plan.error,
            TrufiLocalizations.of(context),
          ),
        );
      }
      return plan;
    } else {
      throw FetchOnlineResponseException('Failed to load plan');
    }
  }

  Future<http.Response> _fetchRequest(Uri request) async {
    try {
      return await http.get(request);
    } catch (e) {
      throw FetchOnlineRequestException(e);
    }
  }

  String _localizedErrorForPlanError(
    PlanError error,
    TrufiLocalizations localizations,
  ) {
    if (error.id == 500 || error.id == 503) {
      return localizations.errorServerUnavailable;
    } else if (error.id == 400) {
      return localizations.errorOutOfBoundary;
    } else if (error.id == 404) {
      return localizations.errorPathNotFound;
    } else if (error.id == 406) {
      return localizations.errorNoTransitTimes;
    } else if (error.id == 408) {
      return localizations.errorServerTimeout;
    } else if (error.id == 409) {
      return localizations.errorTrivialDistance;
    } else if (error.id == 413) {
      return localizations.errorServerCanNotHandleRequest;
    } else if (error.id == 440) {
      return localizations.errorUnknownOrigin;
    } else if (error.id == 450) {
      return localizations.errorUnknownDestination;
    } else if (error.id == 460) {
      return localizations.errorUnknownOriginDestination;
    } else if (error.id == 470) {
      return localizations.errorNoBarrierFree;
    } else if (error.id == 340) {
      return localizations.errorAmbiguousOrigin;
    } else if (error.id == 350) {
      return localizations.errorAmbiguousDestination;
    } else if (error.id == 360) {
      return localizations.errorAmbiguousOriginDestination;
    }
    return error.message;
  }
}

Plan _parsePlan(String responseBody) {
  return Plan.fromJson(json.decode(responseBody));
}

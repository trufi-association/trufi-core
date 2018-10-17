import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphhopper/graphhopper.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/composite_subscription.dart';
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
    return _requestManager.fetchLocations(context, query);
  }

  Future<Plan> fetchPlan(TrufiLocation from, TrufiLocation to) {
    return _requestManager.fetchPlan(from, to);
  }
}

class FetchOfflineRequestIsNotPreparedException implements Exception {}

class FetchOfflineRequestIsNotInitializedException implements Exception {}

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

  Future<Plan> fetchPlan(TrufiLocation from, TrufiLocation to);
}

class OfflineRequestManager implements RequestManager {
  OfflineRequestManager() {
    Future.delayed(Duration.zero, () {
      init();
    });
  }

  static const String externalPath = "/Download/ubilabs/trufi/";

  bool _isPreparing = true;
  bool _isInitialized = false;

  void init() async {
    // Request storage permission
    final List<PermissionGroup> permissions = <PermissionGroup>[
      PermissionGroup.storage
    ];
    final result = await PermissionHandler().requestPermissions(permissions);
    if (result[PermissionGroup.storage] != PermissionStatus.granted) {
      _isPreparing = false;
      return;
    }

    // Copy gtfs and pbf to external storage
    await copyAsset("assets/data/cochabamba-gtfs.zip", externalPath);
    await copyAsset("assets/data/cochabamba.pbf", externalPath);

    // Initialize graphhopper
    try {
      await Graphhopper.gtfsInit(
        externalPath,
        "cochabamba",
      );
      _isInitialized = true;
    } catch (e) {
      print(e);
      _isInitialized = false;
    }
    _isPreparing = false;
  }

  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
  ) async {
    throw FetchOfflineRequestException(
      Exception("Fetch locations offline is not implemented yet."),
    );
  }

  Future<Plan> fetchPlan(TrufiLocation from, TrufiLocation to) async {
    if (_isPreparing) {
      throw FetchOfflineRequestIsNotPreparedException();
    }
    if (!_isInitialized) {
      throw FetchOfflineRequestIsNotInitializedException();
    }
    return Plan.fromGraphhopperJson(
      await Graphhopper.gtfsRoute(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
        "2000-01-01T00:00:00.00Z",
      ),
      from,
      to,
    );
  }

  Future<Null> copyAsset(String key, String path) async {
    final fileName = key.split("/").removeLast();
    final file = new File(
      (await getExternalStorageDirectory()).path + path + fileName,
    );
    if (await file.exists()) {
      await file.delete();
    }
    final data = await rootBundle.load(key);
    await file.create(recursive: true);
    await file.writeAsBytes(data.buffer.asUint8List());
    print("File copied to ${file.toString()}");
  }
}

class OnlineRequestManager implements RequestManager {
  static const String Endpoint = 'trufiapp.westeurope.cloudapp.azure.com';
  static const String SearchPath = '/otp/routers/default/geocode';
  static const String PlanPath = 'otp/routers/default/plan';

  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
  ) async {
    Uri request = Uri.https(Endpoint, SearchPath, {
      "query": query,
      "autocomplete": "false",
      "corners": "true",
      "stops": "false"
    });
    final response = await _fetchRequest(request);
    if (response.statusCode == 200) {
      List<TrufiLocation> locations = await compute(
        _parseLocations,
        utf8.decode(response.bodyBytes),
      );
      final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
      locations.sort((a, b) {
        return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
      });
      return locations;
    } else {
      throw FetchOnlineResponseException('Failed to load locations');
    }
  }

  Future<Plan> fetchPlan(TrufiLocation from, TrufiLocation to) async {
    Uri request = Uri.https(Endpoint, PlanPath, {
      "fromPlace": from.toString(),
      "toPlace": to.toString(),
      "date": "01-01-2018",
      "mode": "TRANSIT,WALK"
    });
    final response = await _fetchRequest(request);
    if (response.statusCode == 200) {
      return compute(_parsePlan, utf8.decode(response.bodyBytes));
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
}

List<TrufiLocation> _parseLocations(String responseBody) {
  return json
      .decode(responseBody)
      .map<TrufiLocation>((json) => new TrufiLocation.fromSearchJson(json))
      .toList();
}

Plan _parsePlan(String responseBody) {
  return Plan.fromJson(json.decode(responseBody));
}

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:routemaster/routemaster.dart';
import 'package:trufi_core/base/pages/about/about.dart';
import 'package:trufi_core/base/pages/feedback/feedback.dart';
import 'package:trufi_core/base/pages/home/home.dart';
import 'package:trufi_core/base/pages/saved_places/saved_places.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list.dart';
import 'package:trufi_core/base/widgets/alerts/error_base_alert.dart';

import 'exception_parse.dart';
import 'geo_location.dart';

class DeeplinkProvider {
  static final DeeplinkProvider _singleton = DeeplinkProvider._internal();

  factory DeeplinkProvider() => _singleton;
  DeeplinkProvider._internal();

  bool _isUsedInitialUri = false;
  bool _isRegisteredListening = false;
  StreamSubscription? _streamSubscription;

  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  Future<void> runService(BuildContext context) async {
    await _initFirstUri(context: context);
    if (!context.mounted) return;
    _registerListening(context: context);
  }

  Future<void> _initFirstUri({
    required BuildContext context,
  }) async {
    if (!_isUsedInitialUri) {
      _isUsedInitialUri = true;
      try {
        final initialURI = await AppLinks().getInitialLink();
        if (initialURI != null && context.mounted) {
          _parseUniLink(context: context, uri: initialURI);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void _registerListening({
    required BuildContext context,
  }) {
    if (!kIsWeb && !_isRegisteredListening) {
      _streamSubscription = AppLinks().uriLinkStream.listen((Uri? uri) {
        if (!context.mounted) return;
        _parseUniLink(context: context, uri: uri);
      }, onError: (e) {
        debugPrint(e.toString());
      });
      _isRegisteredListening = true;
    }
  }

  void _parseUniLink({
    required BuildContext context,
    Uri? uri,
  }) {
    try {
      if (uri?.scheme == GeoLocation.schema) {
        final geoLocation = GeoLocation.fromURI(uri!);
        _cleanNavigatorStore(
          context,
          () => Routemaster.of(context).push(
            HomePage.route,
            queryParameters: geoLocation.toJson(),
          ),
        );
      } else if (uri != null) {
        switch ('/${uri.pathSegments.last}') {
          case HomePage.route:
            _cleanNavigatorStore(
              context,
              () => Routemaster.of(context).push(
                HomePage.route,
                queryParameters: uri.queryParameters,
              ),
            );
            break;
          case TransportList.route:
            _cleanNavigatorStore(
              context,
              () {
                Routemaster.of(context).push(
                  TransportList.route,
                  queryParameters: uri.queryParameters,
                );
              },
            );
            break;
          case SavedPlacesPage.route:
            _cleanNavigatorStore(
              context,
              () => Routemaster.of(context).push(SavedPlacesPage.route),
            );
            break;
          case FeedbackPage.route:
            _cleanNavigatorStore(
              context,
              () => Routemaster.of(context).push(FeedbackPage.route),
            );
            break;
          case AboutPage.route:
            _cleanNavigatorStore(
              context,
              () => Routemaster.of(context).push(AboutPage.route),
            );
            break;
          default:
        }
      }
    } catch (e) {
      if (e is UnilinkParseException) {
        ErrorAlert.showError(
          context: context,
          title: e.title,
          error: e.message,
        );
      } else {
        ErrorAlert.showError(
          context: context,
          error: e.toString(),
        );
      }
    }
  }

  void _cleanNavigatorStore(BuildContext context, Function newNavigator) {
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    newNavigator();
  }
}

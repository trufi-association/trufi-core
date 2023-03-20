import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'package:trufi_core/base/pages/about/about.dart';
import 'package:trufi_core/base/pages/feedback/feedback.dart';
import 'package:trufi_core/base/pages/home/home.dart';
import 'package:trufi_core/base/pages/saved_places/saved_places.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list.dart';
import 'package:uni_links/uni_links.dart';

class UniLinkProvider {
  static final UniLinkProvider _singleton = UniLinkProvider._internal();

  factory UniLinkProvider() => _singleton;
  UniLinkProvider._internal();

  bool _isUsedInitialUri = false;
  bool _isRegisteredListening = false;
  StreamSubscription? _streamSubscription;

  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  Future<void> runService(BuildContext context) async {
    await _initFirstUri(context: context);
    _registerListening(context: context);
  }

  Future<void> _initFirstUri({
    required BuildContext context,
  }) async {
    if (!_isUsedInitialUri) {
      _isUsedInitialUri = true;
      try {
        final initialURI = await getInitialUri();
        if (initialURI != null) {
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
      _streamSubscription = uriLinkStream.listen((Uri? uri) {
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
    if (uri?.host == "maps.google.com") {
      String point;
      if (uri!.path.contains('/maps/place/') ||
          uri.path.contains('/maps/search/')) {
        // Parsing path like "/maps/place/-17.42130622660158+-66.13295530207253/@-17.42130622660158,-66.13295530207253,16z"
        point = uri.path.split('@')[1];
      } else {
        // Parsing query like "q=-17.4223147%2C-66.1442717&z=17&hl=es"
        point = (uri.query.substring(2)).split('&')[0].replaceAll('%2C', ',');
      }
      _cleanNavigatorStore(
        context,
        () => Routemaster.of(context).push(
          HomePage.route,
          queryParameters: {"googlePoint": " ,$point"},
        ),
      );
    } else if (uri?.host == "www.google.com") {
      String point = '';
      if (uri!.path.contains('/maps/place')) {
        // Parsing path: /maps/place/Rutilio+Garde,+Cochabamba/@-17.4370721,-66.1291954,18.9z/data=!4m5!3m4!1s0x93e3719ca85149af:0xe58b826a1f7df603!8m2!3d-17.436793!4d-66.1293789
        final name = uri.path.substring(12).split('/')[0].split(',')[0].replaceAll('+', ' ');
        final location = uri.path.substring(11).split('@')[1].split('/')[0].split(',').take(2).join(',');
        point = "$name,$location";
      }
      _cleanNavigatorStore(
        context,
        () => Routemaster.of(context).push(
          HomePage.route,
          queryParameters: {"googlePoint": point},
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
  }

  void _cleanNavigatorStore(BuildContext context, Function newNavigator) {
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    newNavigator();
  }
}

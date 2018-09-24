// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/history_locations_bloc.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_material_localizations.dart';

import 'mock_http_client.dart';

void main() {
  setUp(() async {
    HttpOverrides.global = new TestHttpOverrides({
      Uri.parse(
              'https://maps.tilehosting.com/styles/positron/5/17/tile.png?key=***REMOVED***'):
          (await rootBundle.load("test/assets/tile.png")).buffer.asUint8List()
    });
  });

  testWidgets('Trufi App - Home Widget', (WidgetTester tester) async {
    await tester.pumpWidget(
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return BlocProvider<LocationProviderBloc>(
          bloc: LocationProviderBloc(),
          child: BlocProvider<FavoriteLocationsBloc>(
              bloc: FavoriteLocationsBloc(),
              child: BlocProvider<HistoryLocationsBloc>(
                  bloc: HistoryLocationsBloc(),
                  child: MaterialApp(localizationsDelegates: [
                    TrufiLocalizationsDelegate(),
                    TrufiMaterialLocalizationsDelegate(),
                    GlobalWidgetsLocalizations.delegate,
                  ], home: HomePage()))));
    }));
    tester.pump();
    HomeRobot().seesMyLocationFab().seesPleaseSelect();
  });
}

class HomeRobot {
  HomeRobot seesMyLocationFab() {
    expect(find.byIcon(Icons.my_location), findsOneWidget);
    return this;
  }

  HomeRobot seesPleaseSelect() {
    expect(find.text("Please select"), findsOneWidget);
    return this;
  }
}

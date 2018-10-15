import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/history_locations_bloc.dart';
import 'package:trufi_app/blocs/important_locations_bloc.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/blocs/request_manager_bloc.dart';
import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/pages/team.dart';
import 'package:trufi_app/trufi_localizations.dart';

void main() {
  runApp(TrufiApp());
}

class TrufiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final preferencesBloc = PreferencesBloc();
    return BlocProvider<PreferencesBloc>(
      bloc: preferencesBloc,
      child: BlocProvider<RequestManagerBloc>(
        bloc: RequestManagerBloc(preferencesBloc),
        child: BlocProvider<LocationProviderBloc>(
          bloc: LocationProviderBloc(),
          child: BlocProvider<FavoriteLocationsBloc>(
            bloc: FavoriteLocationsBloc(context),
            child: BlocProvider<HistoryLocationsBloc>(
              bloc: HistoryLocationsBloc(context),
              child: BlocProvider<ImportantLocationsBloc>(
                bloc: ImportantLocationsBloc(context),
                child: AppLifecycleReactor(
                  child: LocalizedMaterialApp(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppLifecycleReactor extends StatefulWidget {
  const AppLifecycleReactor({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _AppLifecycleReactorState createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor>
    with WidgetsBindingObserver {
  Permission permission = Permission.WriteExternalStorage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    requestPermissionAndCopyGtfsToExternalStorage();
  }

  requestPermissionAndCopyGtfsToExternalStorage() async {
    var writePermission = await SimplePermissions.checkPermission(permission);
    if (!writePermission) {
      await SimplePermissions.requestPermission(permission);
    }
    copyGtfsToExternalStorage('assets/data/cochabamba-gtfs.zip');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final locationProviderBloc = LocationProviderBloc.of(context);
    print("AppLifecycleState: $state");
    setState(() {
      _notification = state;
      if (_notification == AppLifecycleState.resumed) {
        locationProviderBloc.start();
      } else {
        locationProviderBloc.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void copyGtfsToExternalStorage(String gtfsPath) async {
    // load gtfs from assets
    final gtfs = await rootBundle.load(gtfsPath);

    // find file name
    var fileName = gtfsPath.split("/").removeLast();
    var gtfsCopy = new File((await getExternalStorageDirectory()).path + "/" + fileName);

    var gtfsExists = await gtfsCopy.exists();
    if (!gtfsExists){
      gtfsCopy.writeAsBytes(gtfs.buffer.asUint8List());
      print("File copied to " + gtfsCopy.toString());
    }
  }
}

class LocalizedMaterialApp extends StatefulWidget {
  @override
  _LocalizedMaterialAppState createState() => _LocalizedMaterialAppState();
}

class _LocalizedMaterialAppState extends State<LocalizedMaterialApp> {
  @override
  Widget build(BuildContext context) {
    final preferencesBloc = PreferencesBloc.of(context);
    final theme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xffffd600),
      primaryIconTheme: const IconThemeData(color: Colors.black),
    );
    return StreamBuilder(
      stream: preferencesBloc.outChangeLanguageCode,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return MaterialApp(
          routes: <String, WidgetBuilder>{
            AboutPage.route: (context) => AboutPage(),
            FeedbackPage.route: (context) => FeedbackPage(),
            TeamPage.route: (context) => TeamPage(),
          },
          localizationsDelegates: [
            TrufiLocalizationsDelegate(snapshot.data),
            TrufiMaterialLocalizationsDelegate(snapshot.data),
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: locales,
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: HomePage(),
        );
      },
    );
  }
}

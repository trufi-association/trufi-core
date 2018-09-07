import 'dart:async';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trufi_app/about_fragment.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_bloc.dart';
import 'package:trufi_app/location/location_form_field.dart';
import 'package:trufi_app/location/location_search_favorites.dart';
import 'package:trufi_app/location/location_search_history.dart';
import 'package:trufi_app/location/location_search_places.dart';
import 'package:trufi_app/plan_fragment.dart';
import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';

void main() {
  runApp(BlocProvider<LocationBloc>(bloc: LocationBloc(), child: TrufiApp()));
}

class TrufiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData(primaryColor: const Color(0xffffd600));
    return MaterialApp(
      localizationsDelegates: [
        const TrufiLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('de', 'DE'), // German
        const Locale('es', 'ES'), // Spanish
        // ... other locales the app supports
      ],
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: TrufiAppHome(),
    );
  }
}

class TrufiAppHome extends StatefulWidget {
  @override
  _TrufiAppHomeState createState() => _TrufiAppHomeState();
}

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}

class _TrufiAppHomeState extends State<TrufiAppHome>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<TrufiLocation>> _fromFieldKey =
      GlobalKey<FormFieldState<TrufiLocation>>();
  final GlobalKey<FormFieldState<TrufiLocation>> _toFieldKey =
      GlobalKey<FormFieldState<TrufiLocation>>();

  AnimationController controller;
  Animation<double> animation;
  TrufiLocation fromPlace;
  TrufiLocation toPlace;
  Plan plan;

  var drawerItems;
  var drawerOptions = <Widget>[];
  int _selectedDrawerIndex = 0;

  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    animation = Tween(begin: 0.0, end: 42.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    Future.delayed(Duration.zero, () {
      Favorites.init();
      History.init();
      Places.init(this.context);
    });
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    drawerItems = [
      new DrawerItem(
          TrufiLocalizations.of(context).connections, Icons.linear_scale),
      new DrawerItem(TrufiLocalizations.of(context).about, Icons.info),
      new DrawerItem(TrufiLocalizations.of(context).feedback, Icons.create)
    ];
    drawerOptions.clear();
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }

    return Form(
      key: _formKey,
      child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(Theme.of(context)),
          drawer: _buildDrawer()),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    if (_selectedDrawerIndex == 0) {
      return AppBar(
        bottom: PreferredSize(
          child: Container(),
          preferredSize: Size.fromHeight(animation.value),
        ),
        flexibleSpace: _buildFormFields(context),
        leading: _buildResetButton(),
      );
    } else {
      return AppBar();
    }
  }

  Widget _buildFormFields(BuildContext context) {
    List<Row> rows = List();
    bool swapLocationsEnabled = false;
    if (_isFromFieldVisible()) {
      rows.add(
        _buildFormField(_fromFieldKey,
            TrufiLocalizations.of(context).commonOrigin, _setFromPlace,
            initialValue: fromPlace),
      );
      swapLocationsEnabled = true;
    }
    rows.add(
      _buildFormField(_toFieldKey,
          TrufiLocalizations.of(context).commonDestination, _setToPlace,
          trailing: swapLocationsEnabled
              ? GestureDetector(
                  onTap: () => _swapPlaces(),
                  child: Icon(Icons.swap_vert),
                )
              : null),
    );
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: rows,
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    if (!_isFromFieldVisible()) {
      return null;
    }
    return IconButton(
      icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
      onPressed: () => _reset(),
    );
  }

  Widget _buildFormField(
      Key key, String hintText, Function(TrufiLocation) onSaved,
      {TrufiLocation initialValue, Widget leading, Widget trailing}) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 40.0,
          child: leading,
        ),
        Expanded(
          child: LocationFormField(
            key: key,
            hintText: hintText,
            onSaved: onSaved,
            initialValue: initialValue,
          ),
        ),
        SizedBox(
          width: 40.0,
          child: trailing,
        ),
      ],
    );
  }

  bool _isFromFieldVisible() {
    return toPlace != null && controller.isCompleted;
  }

  Widget _buildBody(ThemeData theme, {drawer}) {
    return _getDrawerItemWidget(_selectedDrawerIndex);
  }

  void _reset() {
    _formKey.currentState.reset();
    setState(() {
      fromPlace = null;
      toPlace = null;
      plan = null;
      controller.reverse();
    });
  }

  void _setFromPlace(TrufiLocation value) async {
    setState(() {
      fromPlace = value;
      _fetchPlan();
    });
  }

  void _setToPlace(TrufiLocation value) {
    setState(() {
      toPlace = value;
      if (toPlace != null) {
        controller.forward();
      }
      _fetchPlan();
    });
  }

  void _setPlan(Plan value) {
    setState(() {
      plan = value;
    });
  }

  void _swapPlaces() {
    _toFieldKey.currentState.didChange(fromPlace);
    _fromFieldKey.currentState.didChange(toPlace);
    _toFieldKey.currentState.save();
    _fromFieldKey.currentState.save();
  }

  void _fetchPlan() async {
    final LocationBloc locationBloc = BlocProvider.of<LocationBloc>(context);
    if (toPlace != null) {
      if (fromPlace == null) {
        locationBloc.outLocationUpdate.first.then((location) {
          _setFromPlace(
            TrufiLocation.fromLatLng(
              TrufiLocalizations.of(context).searchCurrentPosition,
              location,
            ),
          );
        });
      } else {
        try {
          _setPlan(await api.fetchPlan(fromPlace, toPlace));
        } on api.FetchRequestException catch (e) {
          print(e);
          String error = TrufiLocalizations.of(context).commonNoInternet;
          _setPlan(Plan.fromError(error));
        } on api.FetchResponseException catch (e) {
          print(e);
          String error = TrufiLocalizations.of(context).searchFailLoadingPlan;
          _setPlan(Plan.fromError(error));
        }
      }
    }
  }

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new PlanFragment(plan);
      case 1:
        return new AboutFragment();
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  _buildDrawer() {
    return new Drawer(
        child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
          DrawerHeader(
            child: Text(TrufiLocalizations.of(context).title),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          new Column(children: drawerOptions)
        ]));
  }
}

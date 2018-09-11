import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/drawer.dart';
import 'package:trufi_app/io/file_storage.dart';
import 'package:trufi_app/location/location_form_field.dart';
import 'package:trufi_app/location/location_search_places.dart';
import 'package:trufi_app/plan/plan_view.dart';
import 'package:trufi_app/trufi_api.dart' as api;
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_map_controller.dart';
import 'package:trufi_app/trufi_models.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final HomePageStateData data = HomePageStateData();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<TrufiLocation>> _fromFieldKey =
      GlobalKey<FormFieldState<TrufiLocation>>();
  final GlobalKey<FormFieldState<TrufiLocation>> _toFieldKey =
      GlobalKey<FormFieldState<TrufiLocation>>();

  AnimationController controller;
  Animation<double> animation;

  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    animation = Tween(begin: 0.0, end: 42.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    Future.delayed(Duration.zero, () {
      Places.init(this.context);
    });
    _loadPlan();
  }

  void _loadPlan() async {
    if (await data.load()) {
      if (data.toPlace != null) {
        setState(() {
          _fromFieldKey.currentState?.didChange(data.fromPlace);
          _toFieldKey.currentState?.didChange(data.toPlace);
          controller.forward();
        });
      }
    }
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
          drawer: TrufiDrawer(HomePage.route,
              onLanguageChangedCallback: () => setState(() {})),
        ));
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      bottom: PreferredSize(
        child: Container(),
        preferredSize: Size.fromHeight(animation.value),
      ),
      flexibleSpace: _buildFormFields(context),
      leading: _buildResetButton(),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    List<Row> rows = List();
    bool swapLocationsEnabled = false;
    if (_isFromFieldVisible()) {
      rows.add(
        _buildFormField(
          _fromFieldKey,
          localizations.commonOrigin,
          _setFromPlace,
          initialValue: data.fromPlace,
        ),
      );
      swapLocationsEnabled = true;
    }
    rows.add(
      _buildFormField(
        _toFieldKey,
        localizations.commonDestination,
        _setToPlace,
        initialValue: data.toPlace,
        trailing: swapLocationsEnabled
            ? GestureDetector(
                onTap: () => _swapPlaces(),
                child: Icon(Icons.swap_vert),
              )
            : null,
      ),
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
    Key key,
    String hintText,
    Function(TrufiLocation) onSaved, {
    TrufiLocation initialValue,
    Widget leading,
    Widget trailing,
  }) {
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
    return data.toPlace != null && controller.isCompleted;
  }

  Widget _buildBody(BuildContext context) {
    PlanError error = data.plan?.error;
    return Container(
      child: error != null
          ? _buildBodyError(error)
          : data.plan != null ? PlanView(data.plan) : _buildBodyEmpty(context),
    );
  }

  Widget _buildBodyError(PlanError error) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          error.message,
        ),
      ),
    );
  }

  Widget _buildBodyEmpty(BuildContext context) {
    LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    return StreamBuilder<LatLng>(
      stream: locationProviderBloc.outLocationUpdate,
      initialData: locationProviderBloc.location,
      builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
        return MapControllerPage(
          initialPosition: snapshot.data,
        );
      },
    );
  }

  void _reset() {
    _formKey.currentState.reset();
    setState(() {
      data.reset();
      controller.reverse();
    });
  }

  void _setFromPlace(TrufiLocation value) async {
    setState(() {
      data.fromPlace = value;
      _fetchPlan();
    });
  }

  void _setToPlace(TrufiLocation value) {
    setState(() {
      data.toPlace = value;
      if (data.toPlace != null) {
        controller.forward();
      }
      _fetchPlan();
    });
  }

  void _setPlan(Plan value) {
    setState(() {
      data.plan = value;
    });
  }

  void _swapPlaces() {
    _toFieldKey.currentState.didChange(data.fromPlace);
    _fromFieldKey.currentState.didChange(data.toPlace);
    _toFieldKey.currentState.save();
    _fromFieldKey.currentState.save();
  }

  void _fetchPlan() async {
    final LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
    if (data.toPlace != null) {
      if (data.fromPlace == null) {
        _setFromPlace(
          TrufiLocation.fromLatLng(
            localizations.searchCurrentPosition,
            locationProviderBloc.location,
          ),
        );
      } else {
        try {
          _setPlan(await api.fetchPlan(data.fromPlace, data.toPlace));
        } on api.FetchRequestException catch (e) {
          print(e);
          _setPlan(Plan.fromError(localizations.commonNoInternet));
        } on api.FetchResponseException catch (e) {
          print(e);
          _setPlan(Plan.fromError(localizations.searchFailLoadingPlan));
        }
      }
    }
  }
}

class HomePageStateData {
  HomePageStateData({
    TrufiLocation fromPlace,
    TrufiLocation toPlace,
    Plan plan,
  }) {
    _fromPlace = fromPlace;
    _toPlace = toPlace;
    _plan = plan;
  }

  static const String _FromPlace = "fromPlace";
  static const String _ToPlace = "toPlace";
  static const String _Plan = "plan";

  final FileStorage storage = FileStorage("home_page_state_data.json");

  TrufiLocation _fromPlace;
  TrufiLocation _toPlace;
  Plan _plan;

  // Json

  factory HomePageStateData.fromJson(Map<String, dynamic> json) {
    return HomePageStateData(
      fromPlace: TrufiLocation.fromJson(json[_FromPlace]),
      toPlace: TrufiLocation.fromJson(json[_ToPlace]),
      plan: Plan.fromJson(json[_Plan]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _FromPlace: fromPlace.toJson(),
      _ToPlace: toPlace.toJson(),
      _Plan: plan.toJson(),
    };
  }

  // Methods

  void reset() {
    fromPlace = null;
    toPlace = null;
    plan = null;
    storage.delete();
  }

  Future<bool> load() async {
    try {
      HomePageStateData data = await compute(_parse, await storage.read());
      if (data != null) {
        fromPlace = data.fromPlace;
        toPlace = data.toPlace;
        plan = data.plan;
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  void _save() async {
    storage.write(json.encode(toJson()));
  }

  // Getter

  TrufiLocation get fromPlace => _fromPlace;

  TrufiLocation get toPlace => _toPlace;

  Plan get plan => _plan;

  // Setter

  set fromPlace(TrufiLocation value) {
    _fromPlace = value;
    _save();
  }

  set toPlace(TrufiLocation value) {
    _toPlace = value;
    _save();
  }

  set plan(Plan value) {
    _plan = value;
    _save();
  }
}

HomePageStateData _parse(String encoded) {
  HomePageStateData data;
  try {
    final parsed = json.decode(encoded);
    data = HomePageStateData.fromJson(parsed);
  } catch (e) {
    print(e);
  }
  return data;
}

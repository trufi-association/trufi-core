import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
import 'package:trufi_app/widgets/alerts.dart';

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

  bool _isFetching = false;

  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Places.init(this.context);
      _init();
    });
  }

  void _init() async {
    if (await data.load() && data.toPlace != null) {
      setState(() {
        _fromFieldKey.currentState?.didChange(data.fromPlace);
        _toFieldKey.currentState?.didChange(data.toPlace);
      });
    } else {
      _setFromPlaceToCurrentPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
          drawer: TrufiDrawer(
            HomePage.route,
            onLanguageChangedCallback: () => setState(() {}),
          ),
        ));
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      bottom: PreferredSize(
        child: Container(),
        preferredSize: Size.fromHeight(40.0),
      ),
      flexibleSpace: _buildFormFields(context),
      leading: data.isResettable ? _buildResetButton() : null,
    );
  }

  Widget _buildFormFields(BuildContext context) {
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            _buildFormField(
              _fromFieldKey,
              localizations.searchPleaseSelect,
              _setFromPlace,
            ),
            _buildFormField(
              _toFieldKey,
              localizations.searchPleaseSelect,
              _setToPlace,
              trailing: data.isSwappable ? _buildSwapButton() : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapButton() {
    return GestureDetector(
      onTap: _swapPlaces,
      child: Icon(Icons.swap_vert),
    );
  }

  Widget _buildResetButton() {
    return IconButton(
      icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
      onPressed: _reset,
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
          ),
        ),
        SizedBox(
          width: 40.0,
          child: trailing,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    Widget body = Container(
      child: data.plan != null && data.plan.error == null
          ? PlanView(data.plan)
          : _buildBodyEmpty(context),
    );
    if (_isFetching) {
      return Stack(
        children: <Widget>[
          Positioned.fill(child: body),
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        ],
      );
    } else {
      return body;
    }
  }

  Widget _buildBodyEmpty(BuildContext context) {
    LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    return StreamBuilder<LatLng>(
      stream: locationProviderBloc.outLocationUpdate,
      builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
        return MapControllerPage(
          initialPosition: snapshot.data,
        );
      },
    );
  }

  void _reset() {
    setState(() {
      data.reset();
      _formKey.currentState.reset();
      _setFromPlaceToCurrentPosition();
    });
  }

  void _setPlaces(TrufiLocation fromPlace, TrufiLocation toPlace) {
    setState(() {
      data.fromPlace = fromPlace;
      data.toPlace = toPlace;
      _toFieldKey.currentState.didChange(data.toPlace);
      _fromFieldKey.currentState.didChange(data.fromPlace);
      _fetchPlan();
    });
  }

  void _setFromPlace(TrufiLocation fromPlace) async {
    setState(() {
      data.fromPlace = fromPlace;
      _fromFieldKey.currentState.didChange(data.fromPlace);
      _fetchPlan();
    });
  }

  void _setFromPlaceToCurrentPosition() async {
    final LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
    final LatLng lastLocation = await locationProviderBloc.lastLocation;
    if (lastLocation != null) {
      _setFromPlace(
        TrufiLocation.fromLatLng(
          localizations.searchCurrentPosition,
          lastLocation,
        ),
      );
    }
  }

  void _setToPlace(TrufiLocation toPlace) {
    setState(() {
      data.toPlace = toPlace;
      _toFieldKey.currentState.didChange(data.toPlace);
      _fetchPlan();
    });
  }

  void _setPlan(Plan plan) {
    setState(() {
      data.plan = plan;
    });
    PlanError error = data.plan?.error;
    if (error != null) {
      showDialog(
        context: context,
        builder: (context) => buildAlert(
              context: context,
              content: error.message,
            ),
      );
    }
  }

  void _swapPlaces() {
    _setPlaces(data.toPlace, data.fromPlace);
  }

  void _fetchPlan() async {
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
    if (data.toPlace != null && data.fromPlace != null) {
      setState(() => _isFetching = true);
      try {
        _setPlan(await api.fetchPlan(data.fromPlace, data.toPlace));
      } on api.FetchRequestException catch (e) {
        print(e);
        _setPlan(Plan.fromError(localizations.commonNoInternet));
      } on api.FetchResponseException catch (e) {
        print(e);
        _setPlan(Plan.fromError(localizations.searchFailLoadingPlan));
      }
      setState(() => _isFetching = false);
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
      _FromPlace: fromPlace != null ? fromPlace.toJson() : null,
      _ToPlace: toPlace != null ? toPlace.toJson() : null,
      _Plan: plan != null ? plan.toJson() : null,
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

  bool get isSwappable => _fromPlace != null && _toPlace != null;

  bool get isResettable => _toPlace != null || _plan != null;

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

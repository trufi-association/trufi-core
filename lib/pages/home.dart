import 'dart:async';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/drawer.dart';
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
          drawer: buildDrawer(context, HomePage.route)),
    );
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
    return toPlace != null && controller.isCompleted;
  }

  Widget _buildBody(BuildContext context) {
    PlanError error = plan?.error;
    return Container(
      child: error != null
          ? _buildBodyError(error)
          : plan != null ? PlanView(plan) : _buildBodyEmpty(context),
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
      builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
        return MapControllerPage();
      },
    );
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
    final LocationProviderBloc locationBloc =
        BlocProvider.of<LocationProviderBloc>(context);
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
}

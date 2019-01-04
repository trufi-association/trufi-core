import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/blocs/request_manager_bloc.dart';
import 'package:trufi_app/composite_subscription.dart';
import 'package:trufi_app/keys.dart' as keys;
import 'package:trufi_app/location/location_form_field.dart';
import 'package:trufi_app/plan/plan.dart';
import 'package:trufi_app/plan/plan_empty.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/widgets/alerts.dart';
import 'package:trufi_app/widgets/trufi_drawer.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _data = HomePageStateData();
  final _formKey = GlobalKey<FormState>();
  final _fromFieldKey = GlobalKey<FormFieldState<TrufiLocation>>();
  final _toFieldKey = GlobalKey<FormFieldState<TrufiLocation>>();
  final _subscriptions = CompositeSubscription();

  bool _isFetching = false;

  @override
  initState() {
    super.initState();
    _subscriptions.add(
      PreferencesBloc.of(context).outChangeOnline.listen((online) {
        if (_data.plan == null) {
          _fetchPlan();
        }
      }),
    );
    Future.delayed(Duration.zero, () {
      _loadState();
    });
  }

  @override
  void dispose() {
    _subscriptions.cancel();
    super.dispose();
  }

  void _loadState() async {
    if (await _data.load(context) && _data.toPlace != null) {
      setState(() {
        _fromFieldKey.currentState?.didChange(_data.fromPlace);
        _toFieldKey.currentState?.didChange(_data.toPlace);
        if (_data.plan == null) {
          _fetchPlan();
        }
      });
    } else {
      _setFromPlaceToCurrentPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey(keys.homePage),
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: TrufiDrawer(HomePage.route),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      bottom: PreferredSize(
        child: Container(),
        preferredSize: Size.fromHeight(45.0),
      ),
      flexibleSpace: _buildFormFields(context),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    final localizations = TrufiLocalizations.of(context);
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildFormField(
                _fromFieldKey,
                ValueKey(keys.homePageFromPlaceField),
                localizations.searchPleaseSelectOrigin,
                localizations.searchHintOrigin,
                _setFromPlace,
                trailing: _data.isResettable ? _buildResetButton() : null,
              ),
              _buildFormField(
                _toFieldKey,
                ValueKey(keys.homePageToPlaceField),
                localizations.searchPleaseSelectDestination,
                localizations.searchHintDestination,
                _setToPlace,
                trailing: _data.isSwappable ? _buildSwapButton() : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwapButton() {
    return FittedBox(
      child: IconButton(
        key: ValueKey(keys.homePageSwapButton),
        icon: Icon(Icons.swap_vert),
        onPressed: _swapPlaces,
      ),
    );
  }

  Widget _buildResetButton() {
    return FittedBox(
      child: IconButton(
        icon: Icon(Icons.clear),
        onPressed: _reset,
      ),
    );
  }

  Widget _buildFormField(
    Key key,
    ValueKey<String> valueKey,
    String hintText,
    String searchHintText,
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
          key: valueKey,
          child: LocationFormField(
            key: key,
            hintText: hintText,
            onSaved: onSaved,
            searchHintText: searchHintText,
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
      child: _data.plan != null && _data.plan.error == null
          ? PlanPage(_data.plan)
          : PlanEmptyPage(),
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
          ),
        ],
      );
    } else {
      return body;
    }
  }

  void _reset() {
    setState(() {
      _data.reset(context);
      _formKey.currentState.reset();
      _setFromPlaceToCurrentPosition();
    });
  }

  void _setPlaces(TrufiLocation fromPlace, TrufiLocation toPlace) {
    setState(() {
      _data.plan = null;
      _data.fromPlace = fromPlace;
      _data.toPlace = toPlace;
      _data.save(context);
      _toFieldKey.currentState.didChange(_data.toPlace);
      _fromFieldKey.currentState.didChange(_data.fromPlace);
      _fetchPlan();
    });
  }

  void _setFromPlace(TrufiLocation fromPlace) async {
    setState(() {
      _data.plan = null;
      _data.fromPlace = fromPlace;
      _data.save(context);
      _fromFieldKey.currentState.didChange(_data.fromPlace);
      _fetchPlan();
    });
  }

  void _setFromPlaceToCurrentPosition() async {
    final locationProviderBloc = LocationProviderBloc.of(context);
    final localizations = TrufiLocalizations.of(context);
    final LatLng lastLocation = await locationProviderBloc.lastLocation;
    if (lastLocation != null) {
      _setFromPlace(
        TrufiLocation.fromLatLng(
          localizations.searchItemYourLocation,
          lastLocation,
        ),
      );
    }
  }

  void _setToPlace(TrufiLocation toPlace) {
    setState(() {
      _data.plan = null;
      _data.toPlace = toPlace;
      _data.save(context);
      _toFieldKey.currentState.didChange(_data.toPlace);
      _fetchPlan();
    });
  }

  void _setPlan(Plan plan) {
    setState(() {
      _data.plan = plan;
      _data.save(context);
    });
  }

  void _swapPlaces() {
    _setPlaces(_data.toPlace, _data.fromPlace);
  }

  void _fetchPlan() async {
    final requestManagerBloc = RequestManagerBloc.of(context);
    final localizations = TrufiLocalizations.of(context);
    if (_data.toPlace != null && _data.fromPlace != null) {
      setState(() => _isFetching = true);
      try {
        Plan plan = await requestManagerBloc.fetchPlan(
          context,
          _data.fromPlace,
          _data.toPlace,
        );
        if (plan.hasError) {
          _showErrorAlert(plan.error.message);
        } else {
          _setPlan(plan);
        }
      } on FetchOfflineRequestException catch (e) {
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(
          "Offline mode is not implemented yet.",
          false,
        );
      } on FetchOfflineResponseException catch (e) {
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(
          "Offline mode is not implemented yet.",
          false,
        );
      } on FetchOnlineRequestException catch (e) {
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(localizations.commonNoInternet, true);
      } on FetchOnlineResponseException catch (e) {
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(localizations.searchFailLoadingPlan, true);
      } catch (e) {
        print("Failed to fetch plan: $e");
      }
      setState(() => _isFetching = false);
    }
  }

  void _showErrorAlert(String error) {
    showDialog(
      context: context,
      builder: (context) {
        return buildErrorAlert(context: context, error: error);
      },
    );
  }

  void _showOnAndOfflineErrorAlert(String message, bool online) {
    showDialog(
      context: context,
      builder: (context) {
        return buildOnAndOfflineErrorAlert(
          context: context,
          online: online,
          title: TrufiLocalizations.of(context).commonError,
          content: message,
        );
      },
    );
  }
}

class HomePageStateData {
  static const String _FromPlace = "fromPlace";
  static const String _ToPlace = "toPlace";
  static const String _Plan = "plan";

  HomePageStateData({this.fromPlace, this.toPlace, this.plan});

  TrufiLocation fromPlace;
  TrufiLocation toPlace;
  Plan plan;

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

  void reset(BuildContext context) async {
    fromPlace = null;
    toPlace = null;
    plan = null;
    PreferencesBloc.of(context).stateHomePage = null;
  }

  Future<bool> load(BuildContext context) async {
    try {
      HomePageStateData data = await compute(
        _parse,
        PreferencesBloc.of(context).stateHomePage,
      );
      if (data != null) {
        fromPlace = data.fromPlace;
        toPlace = data.toPlace;
        plan = data.plan;
        return true;
      }
    } catch (e) {
      print("Failed to load plan: $e");
    }
    return false;
  }

  void save(BuildContext context) async {
    PreferencesBloc.of(context).stateHomePage = json.encode(toJson());
  }

  // Getter

  bool get isSwappable => fromPlace != null && toPlace != null;

  bool get isResettable => toPlace != null || plan != null;
}

HomePageStateData _parse(String encoded) {
  if (encoded != null && encoded.isNotEmpty) {
    try {
      return HomePageStateData.fromJson(json.decode(encoded));
    } catch (e) {
      print("Failed to parse home page state data: $e");
    }
  }
  return HomePageStateData();
}

import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/preferences_bloc.dart';
import 'package:trufi_core/trufi_models.dart';

class MapRouteState {
  static const String _fromPlace = "fromPlace";
  static const String _toPlace = "toPlace";
  static const String _plan = "plan";
  static const String _ad = "ad";

  MapRouteState({
    this.fromPlace,
    this.toPlace,
    this.plan,
    this.ad,
    this.currentFetchAdOperation,
    this.currentFetchPlanOperation,
  });

  TrufiLocation fromPlace;
  TrufiLocation toPlace;
  Plan plan;
  Ad ad;
  CancelableOperation<Plan> currentFetchPlanOperation;
  CancelableOperation<Ad> currentFetchAdOperation;

  MapRouteState copyWith({
    TrufiLocation fromPlace,
    TrufiLocation toPlace,
    Plan plan,
    Ad ad,
    CancelableOperation<Plan> currentFetchPlanOperation,
    CancelableOperation<Ad> currentFetchAdOperation,
  }) {
    return MapRouteState(
      fromPlace: fromPlace ?? this.fromPlace,
      toPlace: toPlace ?? this.toPlace,
      plan: plan ?? this.plan,
      ad: ad ?? this.ad,
      currentFetchAdOperation:
          currentFetchAdOperation ?? this.currentFetchAdOperation,
      currentFetchPlanOperation:
          currentFetchPlanOperation ?? this.currentFetchPlanOperation,
    );
  }

  // Json
  factory MapRouteState.fromJson(Map<String, dynamic> json) {
    return MapRouteState(
      fromPlace:
          TrufiLocation.fromJson(json[_fromPlace] as Map<String, dynamic>),
      toPlace: TrufiLocation.fromJson(json[_toPlace] as Map<String, dynamic>),
      plan: Plan.fromJson(json[_plan] as Map<String, dynamic>),
      ad: Ad.fromJson(json[_ad] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _fromPlace: fromPlace?.toJson(),
      _toPlace: toPlace?.toJson(),
      _plan: plan?.toJson(),
      _ad: ad?.toJson(),
    };
  }

  void save(BuildContext context) {
    BlocProvider.of<PreferencesBloc>(context).updateStateHomePage(
      json.encode(toJson()),
    );
  }

  // Getter
  bool get isSwappable => fromPlace != null && toPlace != null;

  bool get isResettable => toPlace != null || plan != null;

  @override
  String toString() {
    return "fromPlace ${fromPlace?.description}, toPlace ${toPlace?.description}";
  }
}
import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:trufi_core/trufi_models.dart';

class MapRouteState extends Equatable {
  static const String _fromPlace = "fromPlace";
  static const String _toPlace = "toPlace";
  static const String _plan = "plan";
  static const String _ad = "ad";
  static const String _showSuccessAnimation = "animation";
  static const String _isFetching = "fetching";

  const MapRouteState({
    this.fromPlace,
    this.toPlace,
    this.plan,
    this.ad,
    this.isFetching = false,
    this.showSuccessAnimation = false,
    this.currentFetchAdOperation,
    this.currentFetchPlanOperation,
  });

  final TrufiLocation fromPlace;
  final TrufiLocation toPlace;
  final Plan plan;
  final Ad ad;
  final bool isFetching;
  final bool showSuccessAnimation;
  final CancelableOperation<Plan> currentFetchPlanOperation;
  final CancelableOperation<Ad> currentFetchAdOperation;

  MapRouteState copyWith({
    TrufiLocation fromPlace,
    TrufiLocation toPlace,
    Plan plan,
    Ad ad,
    bool isFetching,
    bool showSuccessAnimation,
    CancelableOperation<Plan> currentFetchPlanOperation,
    CancelableOperation<Ad> currentFetchAdOperation,
  }) {
    return MapRouteState(
      fromPlace: fromPlace ?? this.fromPlace,
      toPlace: toPlace ?? this.toPlace,
      plan: plan ?? this.plan,
      ad: ad ?? this.ad,
      isFetching: isFetching ?? this.isFetching,
      showSuccessAnimation: showSuccessAnimation ?? this.showSuccessAnimation,
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
      isFetching: json[_isFetching] as bool ?? false,
      showSuccessAnimation: json[_showSuccessAnimation] as bool ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _fromPlace: fromPlace?.toJson(),
      _toPlace: toPlace?.toJson(),
      _plan: plan?.toJson(),
      _ad: ad?.toJson(),
      _isFetching: isFetching ?? false,
      _showSuccessAnimation: showSuccessAnimation ?? false,
    };
  }

  // Getter
  bool get isSwappable => fromPlace != null && toPlace != null;

  bool get isResettable => toPlace != null || plan != null;

  @override
  String toString() {
    return "fromPlace ${fromPlace?.description}, toPlace ${toPlace?.description}, "
        "isFetching $isFetching, showSuccessAnimation $showSuccessAnimation";
  }

  @override
  List<Object> get props =>
      [fromPlace, toPlace, isFetching, showSuccessAnimation];
}

import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/trufi_place.dart';

class MapRouteState extends Equatable {
  static const String _fromPlace = "fromPlace";
  static const String _toPlace = "toPlace";
  static const String _plan = "plan";
  static const String _modesTransport = "modesTransport";
  static const String _ad = "ad";
  static const String _showSuccessAnimation = "animation";
  static const String _isFetching = "fetching";
  static const String _isFetchingModes = "isFetchingModes";
  static const String _isFetchLater = "isFetchLater";
  static const String _isFetchEarlier = "isFetchEarlier";
  static const String _isFetchingMore = "isFetchingMore";

  const MapRouteState({
    this.fromPlace,
    this.toPlace,
    this.modesTransport,
    this.plan,
    this.ad,
    this.isFetching = false,
    this.isFetchingModes = false,
    this.isFetchLater = false,
    this.isFetchEarlier = false,
    this.isFetchingMore = false,
    this.showSuccessAnimation = false,
  });

  final TrufiLocation fromPlace;
  final TrufiLocation toPlace;
  final PlanEntity plan;
  final ModesTransportEntity modesTransport;
  final AdEntity ad;
  final bool isFetching;
  final bool isFetchingModes;
  final bool isFetchLater;
  final bool isFetchEarlier;
  final bool isFetchingMore;
  final bool showSuccessAnimation;

  MapRouteState copyWith({
    TrufiLocation fromPlace,
    TrufiLocation toPlace,
    PlanEntity plan,
    ModesTransportEntity modesTransport,
    AdEntity ad,
    bool isFetching,
    bool isFetchingModes,
    bool showSuccessAnimation,
    bool isFetchLater,
    bool isFetchEarlier,
    bool isFetchingMore,
    CancelableOperation<PlanEntity> currentFetchPlanOperation,
    CancelableOperation<AdEntity> currentFetchAdOperation,
  }) {
    return MapRouteState(
      fromPlace: fromPlace ?? this.fromPlace,
      toPlace: toPlace ?? this.toPlace,
      plan: plan ?? this.plan,
      modesTransport: modesTransport ?? this.modesTransport,
      ad: ad ?? this.ad,
      isFetching: isFetching ?? this.isFetching,
      isFetchingModes: isFetchingModes ?? this.isFetchingModes,
      isFetchLater: isFetchLater ?? this.isFetchLater,
      isFetchEarlier: isFetchEarlier ?? this.isFetchEarlier,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      showSuccessAnimation: showSuccessAnimation ?? this.showSuccessAnimation,
    );
  }

  MapRouteState copyWithoutMap({
    TrufiLocation fromPlace,
    TrufiLocation toPlace,
    AdEntity ad,
    bool isFetching,
    bool isFetchingModes,
    bool showSuccessAnimation,
    bool isFetchLater,
    bool isFetchEarlier,
    bool isFetchingMore,
    CancelableOperation<PlanEntity> currentFetchPlanOperation,
    CancelableOperation<AdEntity> currentFetchAdOperation,
  }) {
    return MapRouteState(
      fromPlace: fromPlace ?? this.fromPlace,
      toPlace: toPlace ?? this.toPlace,
      ad: ad ?? this.ad,
      isFetching: isFetching ?? this.isFetching,
      isFetchingModes: isFetchingModes ?? this.isFetchingModes,
      isFetchLater: isFetchLater ?? this.isFetchLater,
      isFetchEarlier: isFetchEarlier ?? this.isFetchEarlier,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      showSuccessAnimation: showSuccessAnimation ?? this.showSuccessAnimation,
    );
  }

  MapRouteState copyWithNullable({
    Optional<TrufiLocation> fromPlace = const Optional(),
    Optional<TrufiLocation> toPlace = const Optional(),
    Optional<PlanEntity> plan = const Optional(),
    ModesTransportEntity modesTransport,
    AdEntity ad,
    bool isFetching,
    bool isFetchingModes,
    bool showSuccessAnimation,
    bool isFetchLater,
    bool isFetchEarlier,
    bool isFetchingMore,
    CancelableOperation<PlanEntity> currentFetchPlanOperation,
    CancelableOperation<AdEntity> currentFetchAdOperation,
  }) {
    return MapRouteState(
      fromPlace: fromPlace.isValid ? fromPlace.value : this.fromPlace,
      toPlace: toPlace.isValid ? toPlace.value : this.toPlace,
      plan: plan.isValid ? plan.value : this.plan,
      modesTransport: modesTransport ?? this.modesTransport,
      ad: ad ?? this.ad,
      isFetching: isFetching ?? this.isFetching,
      isFetchingModes: isFetchingModes ?? this.isFetchingModes,
      isFetchLater: isFetchLater ?? this.isFetchLater,
      isFetchEarlier: isFetchEarlier ?? this.isFetchEarlier,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      showSuccessAnimation: showSuccessAnimation ?? this.showSuccessAnimation,
    );
  }

  // Json
  factory MapRouteState.fromJson(Map<String, dynamic> json) {
    return MapRouteState(
      fromPlace:
          TrufiLocation.fromJson(json[_fromPlace] as Map<String, dynamic>),
      toPlace: TrufiLocation.fromJson(json[_toPlace] as Map<String, dynamic>),
      plan: PlanEntity.fromJson(json[_plan] as Map<String, dynamic>),
      modesTransport: json[_modesTransport] != null
          ? ModesTransportEntity.fromJson(
              json[_modesTransport] as Map<String, dynamic>)
          : null,
      ad: AdEntity.fromJson(json[_ad] as Map<String, dynamic>),
      showSuccessAnimation: json[_showSuccessAnimation] as bool ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _fromPlace: fromPlace?.toJson(),
      _toPlace: toPlace?.toJson(),
      _plan: plan?.toJson(),
      _modesTransport: modesTransport?.toJson(),
      _ad: ad?.toJson(),
      _isFetching: isFetching ?? false,
      _isFetchingModes: isFetchingModes ?? false,
      _showSuccessAnimation: showSuccessAnimation ?? false,
      _isFetchLater: isFetchLater ?? false,
      _isFetchEarlier: isFetchEarlier ?? false,
      _isFetchingMore: isFetchingMore ?? false,
    };
  }

  bool get isPlacesDefined => fromPlace != null && toPlace != null;

  bool get hasTransportModes =>
      modesTransport != null && modesTransport.availableModesTransport;

  @override
  String toString() {
    return "fromPlace ${fromPlace?.description}, toPlace ${toPlace?.description}, "
        "isFetching $isFetching, isFetchingModes $isFetchingModes, "
        "showSuccessAnimation $showSuccessAnimation, plan ${plan != null}, "
        "modesTransport ${modesTransport != null} "
        "isFetchLater ${isFetchLater != null}, isFetchEarlier ${isFetchEarlier != null}";
  }

  @override
  List<Object> get props => [
        fromPlace,
        toPlace,
        plan,
        modesTransport,
        isFetching,
        isFetchingModes,
        showSuccessAnimation,
        isFetchLater,
        isFetchEarlier,
        isFetchingMore,
      ];
}

class Optional<T> {
  final bool isValid;
  final T _value;

  T get value => _value;

  const Optional()
      : isValid = false,
        _value = null;
  const Optional.value(this._value) : isValid = true;
}

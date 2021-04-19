import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/widgets/from_marker.dart';
import 'package:trufi_core/widgets/to_marker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/app_review_bloc.dart';
import '../blocs/location_provider_bloc.dart';
import '../blocs/preferences_bloc.dart';
import '../blocs/request_manager_bloc.dart';
import '../composite_subscription.dart';
import '../keys.dart' as keys;
import '../location/location_form_field.dart';
import '../plan/plan.dart';
import '../plan/plan_empty.dart';
import '../trufi_app.dart';
import '../trufi_configuration.dart';
import '../trufi_models.dart';
import '../widgets/alerts.dart';
import '../widgets/app_review_dialog.dart';
import '../widgets/trufi_drawer.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;

  const HomePage(
      {Key key, this.customOverlayWidget, this.customBetweenFabWidget})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _data = HomePageStateData();
  final _formKey = GlobalKey<FormState>();
  final _fromFieldKey = GlobalKey<FormFieldState<TrufiLocation>>();
  final _toFieldKey = GlobalKey<FormFieldState<TrufiLocation>>();
  final _subscriptions = CompositeSubscription();

  bool _isFetching = false;
  CancelableOperation<Plan> _currentFetchPlanOperation;
  CancelableOperation<Ad> _currentFetchAdOperation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscriptions.add(
      TrufiPreferencesBloc.of(context).outChangeOnline.listen((online) {
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
    WidgetsBinding.instance.removeObserver(this);
    _subscriptions.cancel();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final appReviewBloc = AppReviewBloc.of(context);
      if (await appReviewBloc.isAppReviewAppropriate()) {
        showAppReviewDialog(context);
        appReviewBloc.markReviewRequestedForCurrentVersion();
      }
    }
  }

  Future<void> _loadState() async {
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
      key: const ValueKey(keys.homePage),
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: const TrufiDrawer(HomePage.route),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return AppBar(
      bottom: PreferredSize(
        preferredSize: isPortrait
            ? const Size.fromHeight(45.0)
            : const Size.fromHeight(0.0),
        child: Container(),
      ),
      flexibleSpace: isPortrait
          ? _buildFormFieldsPortrait(context)
          : _buildFormFieldsLandscape(context),
    );
  }

  Widget _buildFormFieldsPortrait(BuildContext context) {
    final translations = TrufiLocalization.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 4.0, 4.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildFormField(
                _fromFieldKey,
                const ValueKey(keys.homePageFromPlaceField),
                translations.searchPleaseSelectOrigin,
                const FromMarker(),
                _setFromPlace,
                leading: const SizedBox.shrink(),
                trailing:
                    _data.isResettable ? _buildResetButton(context) : null,
              ),
              _buildFormField(
                _toFieldKey,
                const ValueKey(keys.homePageToPlaceField),
                translations.searchPleaseSelectDestination,
                const ToMarker(),
                _setToPlace,
                leading: const SizedBox.shrink(),
                trailing: _data.isSwappable
                    ? _buildSwapButton(context, Orientation.portrait)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFieldsLandscape(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 4.0, 4.0),
        child: Form(
          key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const SizedBox(
                width: 40.0,
              ),
              Flexible(
                child: _buildFormField(
                  _fromFieldKey,
                  const ValueKey(keys.homePageFromPlaceField),
                  localization.searchPleaseSelectOrigin,
                  const FromMarker(),
                  _setFromPlace,
                ),
              ),
              SizedBox(
                width: 40.0,
                child: _data.isSwappable
                    ? _buildSwapButton(context, Orientation.landscape)
                    : null,
              ),
              Flexible(
                child: _buildFormField(
                  _toFieldKey,
                  const ValueKey(keys.homePageToPlaceField),
                  localization.searchPleaseSelectDestination,
                  const ToMarker(),
                  _setToPlace,
                ),
              ),
              SizedBox(
                width: 40.0,
                child: _data.isResettable ? _buildResetButton(context) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwapButton(BuildContext context, Orientation orientation) {
    return FittedBox(
      child: IconButton(
        key: const ValueKey(keys.homePageSwapButton),
        icon: Icon(
          orientation == Orientation.portrait
              ? Icons.swap_vert
              : Icons.swap_horiz,
          color: Theme.of(context).primaryIconTheme.color,
        ),
        onPressed: _swapPlaces,
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return FittedBox(
      child: IconButton(
        icon: Icon(
          Icons.clear,
          color: Theme.of(context).primaryIconTheme.color,
        ),
        onPressed: _reset,
      ),
    );
  }

  Widget _buildFormField(
    Key key,
    ValueKey<String> valueKey,
    String hintText,
    Widget textLeadingImage,
    Function(TrufiLocation) onSaved, {
    Widget leading,
    Widget trailing,
  }) {
    final children = <Widget>[];

    if (leading != null) {
      children.add(SizedBox(
        width: 40.0,
        child: leading,
      ));
    }

    children.add(Expanded(
      key: valueKey,
      child: LocationFormField(
        key: key,
        hintText: hintText,
        onSaved: onSaved,
        leadingImage: textLeadingImage,
      ),
    ));

    if (trailing != null) {
      children.add(SizedBox(
        width: 40.0,
        child: trailing,
      ));
    }

    return Row(children: children);
  }

  Widget _buildBody(BuildContext context) {
    final cfg = TrufiConfiguration();
    final Widget body = Container(
      child: _data.plan != null && _data.plan.error == null
          ? PlanPage(
              _data.plan,
              _data.ad,
              widget.customOverlayWidget,
              widget.customBetweenFabWidget,
            )
          : PlanEmptyPage(
              onLongPress: _handleOnLongPress,
              customOverlayWidget: widget.customOverlayWidget,
              customBetweenFabWidget: widget.customBetweenFabWidget),
    );
    if (_isFetching) {
      final children = <Widget>[
        Positioned.fill(child: body),
      ];
      if (cfg.animation.loading != null) {
        children.add(
          Positioned.fill(child: cfg.animation.loading),
        );
      }
      return Stack(children: children);
    } else {
      return body;
    }
  }

  void _handleOnLongPress(LatLng point) {
    _setToPlace(
      TrufiLocation.fromLatLng(
        TrufiLocalization.of(context).searchMapMarker,
        point,
      ),
    );
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

  Future<void> _setFromPlace(TrufiLocation fromPlace) async {
    setState(() {
      _data.plan = null;
      _data.fromPlace = fromPlace;
      _data.save(context);
      _fromFieldKey.currentState.didChange(_data.fromPlace);
      _fetchPlan();
    });
  }

  Future<void> _setFromPlaceToCurrentPosition() async {
    final localization = TrufiLocalization.of(context);
    final location = await LocationProviderBloc.of(context).currentLocation;
    if (location != null) {
      _setFromPlace(
        TrufiLocation.fromLatLng(
          localization.searchItemYourLocation,
          location,
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

  void _setAd(Ad ad) {
    setState(() {
      _data.ad = ad;
      _data.save(context);
    });
  }

  void _swapPlaces() {
    _setPlaces(_data.toPlace, _data.fromPlace);
  }

  Future<void> _fetchPlan({bool car = false}) async {
    final requestManagerBloc = RequestManagerBloc.of(context);
    // Cancel the last fetch plan operation for replace with the current request
    if (_currentFetchPlanOperation != null) _currentFetchPlanOperation.cancel();
    final localization = TrufiLocalization.of(context);
    if (_data.toPlace != null && _data.fromPlace != null) {
      // Refresh your location
      final yourLocation = localization.searchItemYourLocation;
      final refreshFromPlace = _data.fromPlace.description == yourLocation;
      final refreshToPlace = _data.toPlace.description == yourLocation;
      if (refreshFromPlace || refreshToPlace) {
        final location = await LocationProviderBloc.of(context).currentLocation;
        if (location != null) {
          if (refreshFromPlace) {
            _data.fromPlace = TrufiLocation.fromLatLng(yourLocation, location);
          }
          if (refreshToPlace) {
            _data.toPlace = TrufiLocation.fromLatLng(yourLocation, location);
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => buildAlertLocationServicesDenied(context),
          );
          return; // Cancel fetch
        }
      }
      // Start fetch
      setState(() => _isFetching = true);
      try {
        _currentFetchPlanOperation = car
            ? requestManagerBloc.fetchCarPlan(
                context,
                _data.fromPlace,
                _data.toPlace,
              )
            : requestManagerBloc.fetchTransitPlan(
                context,
                _data.fromPlace,
                _data.toPlace,
              );

        final Plan plan =
            await _currentFetchPlanOperation.valueOrCancellation(null);

        if (plan == null) {
          throw "Canceled by user";
        } else if (plan.hasError) {
          if (car) {
            _showErrorAlert(plan.error.message);
          } else {
            _showTransitErrorAlert(plan.error.message);
          }
        } else {
          _setPlan(plan);
          AppReviewBloc.of(context).incrementReviewWorthyActions();
        }
      } on FetchOfflineRequestException catch (e) {
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(
          "Offline mode is not implemented yet.",
          false,
        );
      } on FetchOfflineResponseException catch (e) {
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(
          "Offline mode is not implemented yet.",
          false,
        );
      } on FetchOnlineRequestException catch (e) {
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(localization.commonNoInternet, true);
      } on FetchOnlineResponseException catch (e) {
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(
          localization.searchFailLoadingPlan,
          true,
        );
      } catch (e) {
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch plan: $e");
        _showErrorAlert(e.toString());
      }

      try {
        _currentFetchAdOperation =
            requestManagerBloc.fetchAd(context, _data.toPlace);
        final Ad ad = await _currentFetchAdOperation.valueOrCancellation(null);
        _setAd(ad);
      } catch (e, stacktrace) {
        _setAd(null);
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch ad: $e");
        // ignore: avoid_print
        print(stacktrace);
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

  Future<void> _showTransitErrorAlert(String error) async {
    final cfg = TrufiConfiguration();
    final location = await LocationProviderBloc.of(context).currentLocation;
    final languageCode = Localizations.localeOf(context).languageCode;
    final packageInfo = await PackageInfo.fromPlatform();
    showDialog(
      context: context,
      builder: (context) {
        return buildTransitErrorAlert(
          context: context,
          error: error,
          onReportMissingRoute: () {
            launch(
              "${cfg.url.routeFeedback}?lang=$languageCode&geo=${location?.latitude},${location?.longitude}&app=${packageInfo.version}",
            );
          },
          onShowCarRoute: () {
            _fetchPlan(car: true);
          },
        );
      },
    );
  }

  void _showOnAndOfflineErrorAlert(String message, bool online) {
    final localization = TrufiLocalization.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return buildOnAndOfflineErrorAlert(
          context: context,
          online: online,
          title: Text(localization.commonError),
          content: Text(message),
        );
      },
    );
  }
}

class HomePageStateData {
  static const String _fromPlace = "fromPlace";
  static const String _toPlace = "toPlace";
  static const String _plan = "plan";
  static const String _ad = "ad";

  HomePageStateData({this.fromPlace, this.toPlace, this.plan, this.ad});

  TrufiLocation fromPlace;
  TrufiLocation toPlace;
  Plan plan;
  Ad ad;

  // Json

  factory HomePageStateData.fromJson(Map<String, dynamic> json) {
    return HomePageStateData(
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

  // Methods
  void reset(BuildContext context) {
    fromPlace = null;
    toPlace = null;
    plan = null;
    ad = null;
    TrufiPreferencesBloc.of(context).stateHomePage = null;
  }

  Future<bool> load(BuildContext context) async {
    try {
      final HomePageStateData data = await compute(
        _parse,
        TrufiPreferencesBloc.of(context).stateHomePage,
      );
      if (data != null) {
        fromPlace = data.fromPlace;
        toPlace = data.toPlace;
        plan = data.plan;
        ad = data.ad;
        return true;
      }
    } catch (e) {
      // TODO: Replace by proper error handling
      // ignore: avoid_print
      print("Failed to load plan: $e");
    }
    return false;
  }

  void save(BuildContext context) {
    TrufiPreferencesBloc.of(context).stateHomePage = json.encode(toJson());
  }

  // Getter

  bool get isSwappable => fromPlace != null && toPlace != null;

  bool get isResettable => toPlace != null || plan != null;
}

HomePageStateData _parse(String encoded) {
  if (encoded != null && encoded.isNotEmpty) {
    try {
      return HomePageStateData.fromJson(
          json.decode(encoded) as Map<String, dynamic>);
    } catch (e) {
      // TODO: Replace by proper error handling
      // ignore: avoid_print
      print("Failed to parse home page state data: $e");
    }
  }
  return HomePageStateData();
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/request_manager_bloc.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/map_route_state.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:trufi_core/widgets/from_marker.dart';
import 'package:trufi_core/widgets/to_marker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/location_provider_bloc.dart';
import '../keys.dart' as keys;
import '../location/location_form_field.dart';
import '../plan/plan.dart';
import '../plan/plan_empty.dart';
import '../trufi_app.dart';
import '../trufi_configuration.dart';
import '../trufi_models.dart';
import '../widgets/alerts.dart';
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
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fromFieldKey = GlobalKey<FormFieldState<TrufiLocation>>();
  final _toFieldKey = GlobalKey<FormFieldState<TrufiLocation>>();

  @override
  Widget build(BuildContext context) {
    context.watch<HomePageBloc>().stream.listen((value) {
      _toFieldKey.currentState.didChange(value.toPlace);
      _fromFieldKey.currentState.didChange(value.fromPlace);
    });

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
          child: BlocBuilder<HomePageBloc, MapRouteState>(
            builder: (context, state) {
              return Column(
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
                        state.isResettable ? _buildResetButton(context) : null,
                  ),
                  _buildFormField(
                    _toFieldKey,
                    const ValueKey(keys.homePageToPlaceField),
                    translations.searchPleaseSelectDestination,
                    const ToMarker(),
                    _setToPlace,
                    leading: const SizedBox.shrink(),
                    trailing: state.isSwappable
                        ? _buildSwapButton(context, Orientation.portrait)
                        : null,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormFieldsLandscape(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final homePageState = context.watch<HomePageBloc>().state;
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
                child: homePageState.isSwappable
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
                child: homePageState.isResettable
                    ? _buildResetButton(context)
                    : null,
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
        onPressed: () async {
          final homePageBloc = context.read<HomePageBloc>();
          await homePageBloc.swapLocations();
          final plan = await _fetchPlan(homePageBloc.state);
          await homePageBloc.setPlan(plan);
        },
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

  Widget _buildFormField(Key key, ValueKey<String> valueKey, String hintText,
      Widget textLeadingImage, Function(TrufiLocation) onSaved,
      {Widget leading, Widget trailing}) {
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
    final homePageState = context.read<HomePageBloc>().state;
    final Widget body = Container(
      child: homePageState.plan != null && homePageState.plan.error == null
          ? PlanPage(
              homePageState.plan,
              homePageState.ad,
              widget.customOverlayWidget,
              widget.customBetweenFabWidget,
            )
          : PlanEmptyPage(
              onLongPress: _handleOnLongPress,
              customOverlayWidget: widget.customOverlayWidget,
              customBetweenFabWidget: widget.customBetweenFabWidget,
            ),
    );
    if (homePageState.isFetching) {
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
      context.read<HomePageBloc>().reset();
      _formKey.currentState.reset();
      _setFromPlaceToCurrentPosition();
    });
  }

  Future<void> _setFromPlace(TrufiLocation fromPlace) async {
    final homePageBloc = context.read<HomePageBloc>();

    await homePageBloc.setFromPlace(fromPlace);

    final Plan plan = await _fetchPlan(homePageBloc.state);

    await homePageBloc.setPlan(plan);
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

  Future<void> _setToPlace(TrufiLocation toPlace) async {
    final homePageBloc = context.read<HomePageBloc>();
    await homePageBloc.setToPlace(toPlace);
    final plan = await _fetchPlan(homePageBloc.state);
    await homePageBloc.setPlan(plan);
    setState(() {});
  }

  Future<void> _setAd(Ad ad) async {
    final homePageBloc = context.read<HomePageBloc>();
    await homePageBloc.updateHomePageStateData(
      homePageBloc.state.copyWith(ad: ad),
    );
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
            _fetchPlan(context.read<HomePageBloc>().state, car: true);
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

  Future<Plan> _fetchPlan(MapRouteState mapRouteState,
      {bool car = false}) async {
    final requestManagerBloc = BlocProvider.of<RequestManagerBloc>(context);
    // Cancel the last fetch plan operation for replace with the current request
    if (mapRouteState.currentFetchPlanOperation != null) {
      await mapRouteState.currentFetchPlanOperation.cancel();
    }
    final localization = TrufiLocalization.of(context);
    if (mapRouteState.toPlace != null && mapRouteState.fromPlace != null) {
      // Refresh your location
      final yourLocation = localization.searchItemYourLocation;
      final refreshFromPlace =
          mapRouteState.fromPlace.description == yourLocation;
      final refreshToPlace = mapRouteState.toPlace.description == yourLocation;
      if (refreshFromPlace || refreshToPlace) {
        final location = await LocationProviderBloc.of(context).currentLocation;
        if (location != null) {
          if (refreshFromPlace) {
            mapRouteState.fromPlace =
                TrufiLocation.fromLatLng(yourLocation, location);
          }
          if (refreshToPlace) {
            mapRouteState.toPlace =
                TrufiLocation.fromLatLng(yourLocation, location);
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => buildAlertLocationServicesDenied(context),
          );
          return null; // Cancel fetch
        }
      }

      try {
        mapRouteState.currentFetchPlanOperation = car
            ? requestManagerBloc.fetchCarPlan(
                context,
                mapRouteState.fromPlace,
                mapRouteState.toPlace,
              )
            : requestManagerBloc.fetchTransitPlan(
                context,
                mapRouteState.fromPlace,
                mapRouteState.toPlace,
              );

        final Plan plan = await mapRouteState.currentFetchPlanOperation
            .valueOrCancellation(null);

        if (plan == null) {
          throw "Canceled by user";
        } else if (plan.hasError) {
          if (car) {
            _showErrorAlert(plan.error.message);
          } else {
            _showTransitErrorAlert(plan.error.message);
          }
        } else {
          BlocProvider.of<AppReviewCubit>(context)
              .incrementReviewWorthyActions();
          return plan;
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
        mapRouteState.currentFetchAdOperation = requestManagerBloc.fetchAd(
          context,
          mapRouteState.toPlace,
        );
        final Ad ad = await mapRouteState.currentFetchAdOperation
            .valueOrCancellation(null);
        _setAd(ad);
      } catch (e, stacktrace) {
        _setAd(null);
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch ad: $e");
        // ignore: avoid_print
        print(stacktrace);
      }
    }
    return null;
  }
}

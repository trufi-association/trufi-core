import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/map_route_state.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';
import 'package:trufi_core/widgets/from_marker.dart';
import 'package:trufi_core/widgets/to_marker.dart';

import '../blocs/location_provider_cubit.dart';
import '../keys.dart' as keys;
import '../location/location_form_field.dart';
import '../plan/plan.dart';
import '../plan/plan_empty.dart';
import '../trufi_app.dart';
import '../trufi_configuration.dart';
import '../trufi_models.dart';
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

  CancelableOperation<PlanEntity> currentFetchPlanOperation;
  CancelableOperation<Ad> currentFetchAdOperation;

  @override
  Widget build(BuildContext context) {
    context.watch<HomePageCubit>().stream.listen((value) {
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
          child: BlocBuilder<HomePageCubit, MapRouteState>(
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
    final homePageState = context.watch<HomePageCubit>().state;
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
          final homePageBloc = context.read<HomePageCubit>();
          await homePageBloc.swapLocations();
          await _callFetchPlan();
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
    final homePageState = context.read<HomePageCubit>().state;
    final Widget body = Container(
      child: homePageState.plan != null &&
              homePageState.plan.error == null &&
              !homePageState.isFetching
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
      context.read<HomePageCubit>().reset();
      context.read<LocationProviderCubit>().stop();
      _formKey.currentState.reset();
      _setFromPlaceToCurrentPosition();
    });
  }

  Future<void> _setFromPlace(TrufiLocation fromPlace) async {
    final homePageBloc = context.read<HomePageCubit>();
    await homePageBloc.setFromPlace(fromPlace);
    await _callFetchPlan();
  }

  Future<void> _setFromPlaceToCurrentPosition() async {
    final localization = TrufiLocalization.of(context);
    final location =
        await context.read<LocationProviderCubit>().getCurrentLocation();
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
    final homePageBloc = context.read<HomePageCubit>();
    await homePageBloc.setToPlace(toPlace);
    await _callFetchPlan();
  }

  Future<void> _callFetchPlan() async {
    final homePageCubit = context.read<HomePageCubit>();
    final appReviewCubit = context.read<AppReviewCubit>();
    final locationProviderCubit = context.read<LocationProviderCubit>();
    locationProviderCubit.start();
    final correlationId = context.read<PreferencesCubit>().state.correlationId;
    await homePageCubit
        .fetchPlan(correlationId)
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
  }
}

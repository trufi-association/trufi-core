import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';

import 'package:trufi_core/blocs/gps_location/location_provider_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/pages/home/plan_map/setting_panel/setting_panel_cubit.dart';
import 'package:trufi_core/trufi_models.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/utils/util_icons/icons.dart';
import 'package:trufi_core/widgets/alerts.dart';
import 'package:trufi_core/widgets/dialog_edit_text.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';

import '../choose_location.dart';
import 'dialog_select_icon.dart';

class LocationTiler extends StatelessWidget {
  const LocationTiler({
    Key key,
    @required this.location,
    @required this.updateLocation,
    this.removeLocation,
    this.isDefaultLocation = false,
    this.enableSetIcon = false,
    this.enableSetName = false,
    this.enableSetPosition = false,
  }) : super(key: key);

  final TrufiLocation location;
  final bool isDefaultLocation;
  final bool enableSetIcon;
  final bool enableSetName;
  final bool enableSetPosition;
  final Function(TrufiLocation, TrufiLocation) updateLocation;
  final Function(TrufiLocation) removeLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: ElevatedButton(
        onPressed: () {
          if (!location.isLatLngDefined) {
            _changePosition(context);
          }
        },
        child: Row(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.only(right: 15),
                child: Icon(typeToIconData(location.type) ?? Icons.place)),
            Expanded(
              child: Text(
                location.translateValue(localization),
                style: theme.textTheme.bodyText1,
                maxLines: 1,
              ),
            ),
            if (location.isLatLngDefined)
              PopupMenuButton<int>(
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text(
                      "Show route",
                      style: theme.textTheme.bodyText1,
                    ),
                  ),
                  if (enableSetIcon)
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        localization.savedPlacesSetIconLabel,
                        style: theme.textTheme.bodyText1,
                      ),
                    ),
                  if (enableSetName)
                    PopupMenuItem(
                      value: 2,
                      child: Text(
                        localization.savedPlacesSetNameLabel,
                        style: theme.textTheme.bodyText1,
                      ),
                    ),
                  if (enableSetPosition)
                    PopupMenuItem(
                      value: 3,
                      child: Text(
                        localization.savedPlacesSetPositionLabel,
                        style: theme.textTheme.bodyText1,
                      ),
                    ),
                  if (removeLocation != null || location.isLatLngDefined)
                    PopupMenuItem(
                      value: 4,
                      child: Text(
                        localization.savedPlacesRemoveLabel,
                        style: theme.textTheme.bodyText1,
                      ),
                    ),
                ],
                onSelected: (int index) async {
                  if (index == 0) {
                    await _getRoute(context);
                  } else if (index == 1) {
                    await _changeIcon(context);
                  } else if (index == 2) {
                    await _changeName(context);
                  } else if (index == 3) {
                    await _changePosition(context);
                  } else if (index == 4) {
                    if (isDefaultLocation && location.isLatLngDefined) {
                      updateLocation(
                        location,
                        location.copyWith(
                          longitude: 0,
                          latitude: 0,
                        ),
                      );
                    } else {
                      if (removeLocation != null) {
                        removeLocation(location);
                      }
                    }
                  }
                },
              )
            else
              Container(
                height: 45,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getRoute(BuildContext context) async {
    final locationProviderCubit = context.read<LocationProviderCubit>();
    if (locationProviderCubit.state.currentLocation == null) {
      await showDialog(
        context: context,
        builder: (context) => buildAlertLocationServicesDenied(context),
      );
    }
    if (locationProviderCubit.state.currentLocation == null) return;

    final TrufiLocation currentLocation = TrufiLocation.fromLatLng(
      TrufiLocalization.of(context).searchItemYourLocation,
      locationProviderCubit.state.currentLocation,
    );

    final homePageCubit = context.read<HomePageCubit>();
    final appReviewCubit = context.read<AppReviewCubit>();
    final correlationId = context.read<PreferencesCubit>().state.correlationId;
    final settingPanelCubit = context.read<SettingPanelCubit>();
    await homePageCubit.updateCurrentRoute(currentLocation, location);
    homePageCubit
        .fetchPlan(correlationId, advancedOptions: settingPanelCubit.state)
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
    Navigator.pop(context);
  }

  Future<void> _changeIcon(BuildContext context) async {
    final type = await showDialog<String>(
      context: context,
      builder: (context) => const DialogSelectIcon(),
    );
    updateLocation(location, location.copyWith(type: type));
  }

  Future<void> _changeName(BuildContext context) async {
    final String description = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogEditText(initText: location.description);
        });
    updateLocation(location, location.copyWith(description: description));
  }

  Future<void> _changePosition(BuildContext context) async {
    final LatLng mapLocation = await ChooseLocationPage.selectPosition(
      context,
      position: location.isLatLngDefined ? LatLng(location.latitude, location.longitude) : null,
    );
    updateLocation(
      location,
      location.copyWith(longitude: mapLocation.longitude, latitude: mapLocation.latitude),
    );
  }
}

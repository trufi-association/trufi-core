import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';

import 'package:trufi_core/blocs/gps_location/location_provider_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/pages/home/home_page.dart';
import 'package:trufi_core/pages/home/plan_map/setting_panel/setting_panel_cubit.dart';
import 'package:trufi_core/trufi_models.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/utils/util_icons/icons.dart';
import 'package:trufi_core/widgets/alerts.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';
import 'package:trufi_core/widgets/set_description_dialog.dart';

import '../choose_location.dart';

class LocationTiler extends StatelessWidget {
  static const icons = <String, IconData>{
        'saved_place:home': Icons.home,
        'saved_place:work': Icons.work,
        'saved_place:fastfood': Icons.fastfood,
        'saved_place:local_cafe': Icons.local_cafe,
        'saved_place:map': Icons.map,
        'saved_place:school': Icons.school,
      };

  const LocationTiler({
    Key key,
    @required this.location,
    @required this.removeLocation,
    @required this.updateLocation,
    this.enableSetIcon = false,
    this.enableSetName = false,
    this.enableSetPosition = false,
  }) : super(key: key);

  final TrufiLocation location;
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
        onPressed: null,
        onLongPress: () {
          _showCurrentRoute(context);
        },
        child: Row(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.only(right: 15),
                child: Icon(typeToIconData(location.type)??Icons.place)),
            Expanded(
              child: Text(
                location.description,
                style: theme.textTheme.bodyText1,
                maxLines: 1,
              ),
            ),
            PopupMenuButton<int>(
              itemBuilder: (BuildContext context) => [
                if (enableSetIcon)
                  PopupMenuItem(
                    value: 1,
                    child: Text(
                      localization.savedPlacesSetIconLabel,
                      style: theme.textTheme.bodyText1,
                    ),
                  )
                else
                  null,
                if (enableSetName)
                  PopupMenuItem(
                    value: 2,
                    child: Text(
                      localization.savedPlacesSetNameLabel,
                      style: theme.textTheme.bodyText1,
                    ),
                  )
                else
                  null,
                if (enableSetPosition)
                  PopupMenuItem(
                    value: 3,
                    child: Text(
                      localization.savedPlacesSetPositionLabel,
                      style: theme.textTheme.bodyText1,
                    ),
                  )
                else
                  null,
                if (removeLocation != null)
                  PopupMenuItem(
                    value: 4,
                    child: Text(
                      localization.savedPlacesRemoveLabel,
                      style: theme.textTheme.bodyText1,
                    ),
                  )
                else
                  null,
              ],
              onSelected: (int index) async {
                if (index == 1) {
                  await _changeIcon(context);
                } else if (index == 2) {
                  await _changeName(context);
                } else if (index == 3) {
                  await _changePosition(context);
                } else if (index == 4) {
                  removeLocation(location);
                }
              },
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _showCurrentRoute(BuildContext context) async {
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
    await homePageCubit
        .fetchPlan(correlationId,advancedOptions: settingPanelCubit.state)
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
    Navigator.pushNamed(context, HomePage.route);
  }

  Future<void> _changeIcon(BuildContext context) async {
    final localization = TrufiLocalization.of(context);
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(localization.savedPlacesSelectIconTitle),
        children: <Widget>[
          SizedBox(
            width: 200,
            height: 200,
            child: GridView.builder(
              itemCount: icons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemBuilder: (BuildContext builderContext, int index) {
                return InkWell(
                  onTap: () {
                     updateLocation(location, location.copyWith(type: icons.keys.toList()[index]));
                    Navigator.pop(builderContext);
                  },
                  child: Icon(icons.values.toList()[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeName(BuildContext context) async {
    final String description = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SetDescriptionDialog(initText: location.description);
        });
    if (description != null) {
      updateLocation(
        location,
        location.copyWith(description: description),
      );
    }
  }

  Future<void> _changePosition(BuildContext context) async {
    final LatLng mapLocation = await ChooseLocationPage.selectPosition(context);
    if (mapLocation != null) {
      updateLocation(
        location,
        location.copyWith(
          longitude: mapLocation.longitude,
          latitude: mapLocation.latitude,
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/pages/saved_places/dialog_edit_location.dart';
import 'package:trufi_core/utils/util_icons/icons.dart';

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
    this.enableLocation = false,
    this.enableSetPosition = false,
  }) : super(key: key);

  final TrufiLocation location;
  final bool isDefaultLocation;
  final bool enableSetIcon;
  final bool enableLocation;
  final bool enableSetPosition;
  final Function(TrufiLocation, TrufiLocation) updateLocation;
  final Function(TrufiLocation) removeLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return GestureDetector(
      onTap: () {
        if (!location.isLatLngDefined) {
          _changePosition(context);
        }
      },
      child: Card(
        child: Row(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  typeToIconData(location.type) ?? Icons.place,
                )),
            Expanded(
              child: Text(
                location.displayName(localization),
                style: theme.textTheme.bodyText1
                    .copyWith(color: theme.primaryColor),
                maxLines: 1,
              ),
            ),
            if (location.isLatLngDefined)
              PopupMenuButton<int>(
                itemBuilder: (BuildContext context) => [
                  if (enableSetIcon)
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          const Icon(Icons.edit),
                          const SizedBox(width: 10),
                          Text(
                            localization.savedPlacesSetIconLabel,
                            style: theme.textTheme.bodyText1,
                          ),
                        ],
                      ),
                    ),
                  if (enableLocation)
                    PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          const Icon(Icons.edit),
                          const SizedBox(width: 10),
                          Text(
                            localization.localeName == 'de'
                                ? "Bearbeiten"
                                : "Edit",
                            style: theme.textTheme.bodyText1,
                          ),
                        ],
                      ),
                    ),
                  if (enableSetPosition)
                    PopupMenuItem(
                      value: 3,
                      child: Row(
                        children: [
                          const Icon(Icons.edit_location_alt),
                          const SizedBox(width: 10),
                          Text(
                            localization.savedPlacesSetPositionLabel,
                            style: theme.textTheme.bodyText1,
                          ),
                        ],
                      ),
                    ),
                  if (removeLocation != null || location.isLatLngDefined)
                    PopupMenuItem(
                      value: 4,
                      child: Row(
                        children: [
                          const Icon(Icons.delete),
                          const SizedBox(width: 10),
                          Text(
                            localization.savedPlacesRemoveLabel.split(' ')[0],
                            style: theme.textTheme.bodyText1,
                          ),
                        ],
                      ),
                    ),
                ],
                onSelected: (int index) async {
                  if (index == 1) {
                    await _changeIcon(context);
                  } else if (index == 2) {
                    await _changeLocation(context);
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

  Future<void> _changeIcon(BuildContext context) async {
    final type = await showDialog<String>(
      context: context,
      builder: (context) => const DialogSelectIcon(),
    );
    updateLocation(location, location.copyWith(type: type));
  }

  Future<void> _changeLocation(BuildContext context) async {
    final TrufiLocation newLocation = await showDialog<TrufiLocation>(
        context: context,
        builder: (BuildContext context) {
          return DialogEditLocation(location: location);
        });
    if (newLocation != null) updateLocation(location, newLocation);
  }

  Future<void> _changePosition(BuildContext context) async {
    final ChooseLocationDetail chooseLocationDetail =
        await ChooseLocationPage.selectPosition(
      context,
      position: location.isLatLngDefined
          ? LatLng(location.latitude, location.longitude)
          : null,
    );
    if (chooseLocationDetail != null) {
      updateLocation(
        location,
        location.copyWith(
          longitude: chooseLocationDetail.location.longitude,
          latitude: chooseLocationDetail.location.latitude,
        ),
      );
    }
  }
}

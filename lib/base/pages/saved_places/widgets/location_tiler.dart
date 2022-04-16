import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/widgets/dialog_edit_location.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/util_icons/icons.dart';
import 'package:trufi_core/base/widgets/choose_location/choose_location.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';
import 'dialog_select_icon.dart';

class LocationTiler extends StatelessWidget {
  const LocationTiler({
    Key? key,
    required this.location,
    required this.updateLocation,
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
  final Function(TrufiLocation)? removeLocation;
  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    final localizationSP = SavedPlacesLocalization.of(context);
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
              child: typeToIconData(location.type),
            ),
            Expanded(
              child: Text(
                location.displayName(localizationSP),
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
                            localizationSP.savedPlacesSetIconLabel,
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
                            localization.commonEdit,
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
                            localizationSP.savedPlacesSetPositionLabel,
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
                            localization.commonRemove,
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
                        removeLocation!(location);
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
    final type = await showTrufiDialog<String>(
      context: context,
      builder: (context) => const DialogSelectIcon(),
    );
    updateLocation(location, location.copyWith(type: type));
  }

  Future<void> _changeLocation(BuildContext context) async {
    final TrufiLocation? newLocation = await showTrufiDialog<TrufiLocation?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return DialogEditLocation(
            location: location,
          );
        });
    if (newLocation != null) updateLocation(location, newLocation);
  }

  Future<void> _changePosition(BuildContext context) async {
    final LocationDetail? chooseLocationDetail =
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
          longitude: chooseLocationDetail.position.longitude,
          latitude: chooseLocationDetail.position.latitude,
        ),
      );
    }
  }
}

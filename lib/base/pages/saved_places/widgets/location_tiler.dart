import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/widgets/dialog_edit_location.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/util_icons/icons.dart';
import 'package:trufi_core/base/widgets/choose_location/choose_location.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';
import 'dialog_select_icon.dart';

class LocationTiler extends StatefulWidget {
  const LocationTiler({
    super.key,
    required this.location,
    required this.updateLocation,
    required this.selectPositionOnPage,
    this.removeLocation,
    this.isDefaultLocation = false,
    this.enableSetIcon = false,
    this.enableLocation = false,
    this.enableSetPosition = false,
  });

  final TrufiLocation location;
  final bool isDefaultLocation;
  final bool enableSetIcon;
  final bool enableLocation;
  final bool enableSetPosition;
  final SelectLocationData selectPositionOnPage;
  final Function(TrufiLocation, TrufiLocation) updateLocation;
  final Function(TrufiLocation)? removeLocation;

  @override
  State<LocationTiler> createState() => _LocationTilerState();
}

class _LocationTilerState extends State<LocationTiler> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor, context: context);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!stopDefaultButtonEvent) {
      Navigator.of(context).pop();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    final localizationSP = SavedPlacesLocalization.of(context);
    return GestureDetector(
      onTap: () {
        if (!widget.location.isLatLngDefined) {
          _changePosition(context);
        }
      },
      child: Card(
        child: Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: typeToIconData(widget.location.type),
            ),
            Expanded(
              child: Text(
                widget.location.displayName(localizationSP),
                maxLines: 1,
              ),
            ),
            if (widget.location.isLatLngDefined)
              PopupMenuButton<int>(
                itemBuilder: (BuildContext context) => [
                  if (widget.enableSetIcon)
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
                  if (widget.enableLocation)
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
                  if (widget.enableSetPosition)
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
                  if (widget.removeLocation != null ||
                      widget.location.isLatLngDefined)
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
                    if (widget.isDefaultLocation &&
                        widget.location.isLatLngDefined) {
                      widget.updateLocation(
                        widget.location,
                        widget.location.copyWith(
                          longitude: 0,
                          latitude: 0,
                        ),
                      );
                    } else {
                      if (widget.removeLocation != null) {
                        widget.removeLocation!(widget.location);
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
    widget.updateLocation(
        widget.location, widget.location.copyWith(type: type));
  }

  Future<void> _changeLocation(BuildContext context) async {
    final TrufiLocation? newLocation = await showTrufiDialog<TrufiLocation?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return DialogEditLocation(
            location: widget.location,
            selectPositionOnPage: widget.selectPositionOnPage,
          );
        });
    if (newLocation != null)
      widget.updateLocation(widget.location, newLocation);
  }

  Future<void> _changePosition(BuildContext context) async {
    final LocationDetail? chooseLocationDetail =
        await widget.selectPositionOnPage(
      context,
      position: widget.location.isLatLngDefined
          ? TrufiLatLng(widget.location.latitude, widget.location.longitude)
          : null,
    );
    if (chooseLocationDetail != null) {
      widget.updateLocation(
        widget.location,
        widget.location.copyWith(
          longitude: chooseLocationDetail.position.longitude,
          latitude: chooseLocationDetail.position.latitude,
        ),
      );
    }
  }
}

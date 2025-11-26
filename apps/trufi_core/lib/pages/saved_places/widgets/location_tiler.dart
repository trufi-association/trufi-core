import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:tr_translations/tr_translations.dart';

import 'package:trufi_core/pages/saved_places/widgets/dialog_edit_location.dart';
import 'package:trufi_core/pages/saved_places/widgets/dialog_select_icon.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/utils/icon_utils/icons.dart';

typedef SelectLocationData =
    Future<TrufiLocation?> Function(
      BuildContext context, {
      LatLng? position,
      bool? isOrigin,
    });

class LocationTiler extends StatefulWidget {
  const LocationTiler({
    required this.location,
    required this.updateLocation,
    required this.selectPositionOnPage,
    super.key,
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
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
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
                widget.location.displayName(TrufiLocalizationsProvider.of(context)),
                maxLines: 1,
              ),
            ),
            if (widget.location.isLatLngDefined)
              PopupMenuButton<int>(
                itemBuilder: (BuildContext context) => [
                  if (widget.enableSetIcon)
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 10),
                          Text('Set Icon'),
                        ],
                      ),
                    ),
                  if (widget.enableLocation)
                    const PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  if (widget.enableSetPosition)
                    const PopupMenuItem(
                      value: 3,
                      child: Row(
                        children: [
                          Icon(Icons.edit_location_alt),
                          SizedBox(width: 10),
                          Text('Set Position'),
                        ],
                      ),
                    ),
                  if (widget.removeLocation != null ||
                      widget.location.isLatLngDefined)
                    const PopupMenuItem(
                      value: 4,
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 10),
                          Text('Remove'),
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
                        widget.location.copyWith(position: const LatLng(0, 0)),
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
              Container(height: 45),
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
    widget.updateLocation(
      widget.location,
      widget.location.copyWith(type: TrufiLocationType.fromString(type)),
    );
  }

  Future<void> _changeLocation(BuildContext context) async {
    final newLocation = await showDialog<TrufiLocation?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DialogEditLocation(
          location: widget.location,
          selectPositionOnPage: widget.selectPositionOnPage,
        );
      },
    );
    if (newLocation != null) {
      widget.updateLocation(widget.location, newLocation);
    }
  }

  Future<void> _changePosition(BuildContext context) async {
    final chooseLocationDetail = await widget.selectPositionOnPage(
      context,
      position: widget.location.isLatLngDefined
          ? widget.location.position
          : null,
    );
    if (chooseLocationDetail != null) {
      widget.updateLocation(
        widget.location,
        widget.location.copyWith(
          position: LatLng(
            chooseLocationDetail.position.latitude,
            chooseLocationDetail.position.longitude,
          ),
        ),
      );
    }
  }
}

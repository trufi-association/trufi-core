import 'package:flutter/material.dart';
import 'package:trufi_core/trufi_localizations.dart';
import 'package:uni_links/uni_links.dart' as uniLink;

import '../blocs/saved_locations_bloc.dart';
import '../widgets/alerts.dart';
import '../widgets/set_description_dialog.dart';
import '../trufi_models.dart';

class ImportLocations {
  ImportLocations({
    @required this.setFromPlaceToCurrentPosition,
    @required this.setToPlace,
    @required this.setFromPlaces,
  });

  Function() setFromPlaceToCurrentPosition;
  Function(TrufiLocation) setToPlace;
  Function(TrufiLocation) setFromPlaces;

  Future<bool> importData(BuildContext context) async {
    Uri importData = await uniLink.getInitialUri();
    if (_isCorrectQuery(importData?.query ?? '')) {
      String type = importData?.queryParameters['type'];
      switch (type) {
        case 'location':
          await _optionsLocation(context, importData);
          break;
        case 'route':
          await _showImportRoute(importData);
          break;
        default:
      }
      return true;
    } else {
      if (importData != null) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return buildErrorAlert(
              context: context,
              error: 'the shared link is not correct',
            );
          },
        );
      }
      return false;
    }
  }

  Future<void> _optionsLocation(BuildContext context, Uri uri) async {
    String description = uri?.queryParameters['description'];
    double lat = double.tryParse(uri?.queryParameters['lat']);
    double lng = double.tryParse(uri?.queryParameters['lng']);
    TrufiLocation location =
        TrufiLocation(description: description, latitude: lat, longitude: lng);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          backgroundColor: Theme.of(context).primaryColor,
          contentPadding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _showRouteToLocation(context, location),
              _saveLocation(context, location),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showImportRoute(Uri uri) async {
    String origin = uri?.queryParameters['origin'];
    double lato = double.tryParse(uri?.queryParameters['lato']);
    double lngo = double.tryParse(uri?.queryParameters['lngo']);
    String destiny = uri?.queryParameters['destiny'] ?? 'Nameless';
    double latd = double.tryParse(uri?.queryParameters['latd']);
    double lngd = double.tryParse(uri?.queryParameters['lngd']);
    TrufiLocation originLocation =
        TrufiLocation(description: origin, latitude: lato, longitude: lngo);
    TrufiLocation destinyLocation =
        TrufiLocation(description: destiny, latitude: latd, longitude: lngd);
    await setFromPlaces(originLocation);
    await setToPlace(destinyLocation);
  }

  Widget _showRouteToLocation(
      BuildContext context, TrufiLocation locationDestiny) {
    final localization = TrufiLocalizations.of(context).localization;
    return Container(
      width: double.infinity,
      child: RaisedButton(
        onPressed: () async {
          setFromPlaceToCurrentPosition();
          setToPlace(locationDestiny);
          Navigator.of(context).pop();
        },
        child: Text(localization.menuConnections()),
      ),
    );
  }

  Widget _saveLocation(BuildContext context, TrufiLocation location) {
    final localization = TrufiLocalizations.of(context).localization;
    final SavedLocationsBloc savedLocationsBloc =
        SavedLocationsBloc.of(context);
    return Container(
      width: double.infinity,
      child: RaisedButton(
        onPressed: () async {
          final String description = await showDialog(
            context: context,
            builder: (BuildContext context){
              return SetDescriptionDialog(
              initText: location.description);
            }
          );
          if (description != null) {
            savedLocationsBloc.inAddLocation.add(
              TrufiLocation(
                description: description,
                latitude: location.latitude,
                longitude: location.longitude,
                type: 'saved_place:map',
              ),
            );
          }
          Navigator.of(context).pop();
        },
        child: Text(localization.savedSectionSaveLocation()),
      ),
    );
  }

  //Link for share
  //Lick location --> https://trotro.app?type=route&origin=Atomic&lngo=-0.2659963&lato=5.527639&destiny=Challenge&lngd=-0.209728&latd=5.576912
  //Link route     -->https://trotro.app?type=location&description=Atomic&lng=-0.2659963&lat=5.527639
  bool _isCorrectQuery(String uri) {
    RegExp regexRoute = RegExp(
      r'type=route&origin=[^ ]+&lngo=(-?[0-9]+.[0-9]+)&lato=(-?[0-9]+.[0-9]+)&destiny=[^ ]+&lngd=(-?[0-9]+.[0-9]+)&latd=(-?[0-9]+.[0-9]+)',
      multiLine: false,
    );
    RegExp regexLoaction = RegExp(
      r'type=location&description=[^ ]+&lng=(-?[0-9]+.[0-9]+)&lat=(-?[0-9]+.[0-9]+)',
      multiLine: false,
    );
    return regexRoute.hasMatch(uri) || regexLoaction.hasMatch(uri);
  }
}

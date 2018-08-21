import 'dart:async';

import 'package:composite_subscription/composite_subscription.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as pkg_location;
import 'package:map_view/map_view.dart';
import 'package:trufi_app/trufi_models.dart' as models;
import 'package:trufi_app/ui/location_search_delegate.dart';

class LocationField extends StatefulWidget {
  const LocationField(
      {this.fieldKey,
      this.hintText,
      this.labelText,
      this.helperText,
      this.onSaved,
      this.validator,
      this.onFieldSubmitted,
      this.staticMapProvider,
      this.mapView});

  final Key fieldKey;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final ValueChanged<models.Location> onFieldSubmitted;
  final StaticMapProvider staticMapProvider;
  final MapView mapView;

  @override
  LocationFieldState createState() => new LocationFieldState();
}

class LocationFieldState extends State<LocationField> {
  final CompositeSubscription _compositeSubscription =
      new CompositeSubscription();
  final LocationSearchDelegate _delegate = new LocationSearchDelegate();
  final FocusNode _focusNode = new FocusNode();
  final TextEditingController _textEditController = new TextEditingController();

  CameraPosition cameraPosition;
  Uri staticMapUri;

  models.Location location;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      _showSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new Expanded(
            child: new TextFormField(
          key: widget.fieldKey,
          onSaved: widget.onSaved,
          validator: widget.validator,
          focusNode: _focusNode,
          controller: _textEditController,
          decoration: new InputDecoration(
            border: const UnderlineInputBorder(),
            filled: true,
            hintText: widget.hintText,
            labelText: widget.labelText,
            helperText: widget.helperText,
          ),
        )),
        new Center(
            child: new IconButton(
                icon: new Icon(Icons.add_location), onPressed: _showMap))
      ],
    ));
  }

  _showSearch() async {
    _setLocation(await showSearch(context: context, delegate: _delegate));
    setState(() {
      _textEditController.text = location?.description ?? "";
    });
  }

  Marker _positionMarker;

  _showMap() async {
    pkg_location.Location l = pkg_location.Location();
    Map<String, double> currentLocation = await l.getLocation();
    _positionMarker = _createMarker(
        currentLocation["latitude"], currentLocation["longitude"]);

    widget.mapView.show(
        new MapOptions(
            mapViewType: MapViewType.normal,
            showUserLocation: true,
            showMyLocationButton: true,
            showCompassButton: true,
            initialCameraPosition: new CameraPosition(
                new Location(
                    currentLocation["latitude"], currentLocation["longitude"]),
                15.0),
            hideToolbar: false,
            title: "Choose start position"),
        toolbarActions: [
          new ToolbarAction("❌", 1),
          new ToolbarAction("✔️", 2)
        ]);
    StreamSubscription sub = widget.mapView.onMapReady.listen((_) {
      widget.mapView.setMarkers(<Marker>[_positionMarker]);
    });
    _compositeSubscription.add(sub);
    sub = widget.mapView.onLocationUpdated.listen((location) {
      print("Location updated $location");
    });
    _compositeSubscription.add(sub);
    sub = widget.mapView.onMapTapped.listen((location) {
      widget.mapView.removeMarker(_positionMarker);
      _positionMarker = _createMarker(location.latitude, location.longitude);
      widget.mapView.addMarker(_positionMarker);
    });
    _compositeSubscription.add(sub);
    sub = widget.mapView.onCameraChanged.listen((cameraPosition) =>
        this.setState(() => this.cameraPosition = cameraPosition));
    _compositeSubscription.add(sub);
    sub = widget.mapView.onToolbarAction.listen((id) {
      print("Toolbar button id = $id");
      _hideMap(id != 1);
    });
    _compositeSubscription.add(sub);
  }

  Marker _createMarker(double latitude, double longitude) {
    return new Marker(
      "1",
      "Position",
      latitude,
      longitude,
      color: Colors.blue,
      draggable: true,
      markerIcon: new MarkerIcon(
        "images/marker.png",
        width: 64.0,
        height: 64.0,
      ),
    );
  }

  _hideMap(bool submit) async {
    if (submit) {
      Location centerLocation = await widget.mapView.centerLocation;
      location = new models.Location(
          description: centerLocation.toString(),
          latitude: centerLocation.latitude,
          longitude: centerLocation.longitude);
      print("Center: $centerLocation");
      var uri = await widget.staticMapProvider
          .getImageUriFromMap(widget.mapView, width: 900, height: 400);
      setState(() => staticMapUri = uri);
    }
    widget.mapView.dismiss();
    _compositeSubscription.cancel();
  }

  _setLocation(models.Location location) {
    this.location = location;
    widget.onFieldSubmitted(location);
  }
}

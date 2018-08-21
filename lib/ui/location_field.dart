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
      this.onFieldSubmitted,
      this.mapView});

  final Key fieldKey;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<models.Location> onSaved;
  final ValueChanged<models.Location> onFieldSubmitted;
  final MapView mapView;

  @override
  LocationFieldState createState() => new LocationFieldState();
}

class LocationFieldState extends State<LocationField> {
  final CompositeSubscription _compositeSubscription =
      new CompositeSubscription();
  final LocationSearchDelegate _searchDelegate = new LocationSearchDelegate();
  final FocusNode _focusNode = new FocusNode();
  final TextEditingController _textEditController = new TextEditingController();

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
          onSaved: (value) {
            widget.onSaved(location);
          },
          onFieldSubmitted: (value) {
            widget.onFieldSubmitted(location);
          },
          validator: _validate,
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

  String _validate(String value) {
    if (location == null) {
      return 'Please choose a location.';
    }
    return null;
  }

  _showSearch() async {
    _setLocation(await showSearch(context: context, delegate: _searchDelegate));
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
    _compositeSubscription.add(sub);

    // Replace marker on map tap
    sub = widget.mapView.onMapTapped.listen((location) {
      widget.mapView.removeMarker(_positionMarker);
      _positionMarker = _createMarker(location.latitude, location.longitude);
      widget.mapView.addMarker(_positionMarker);
    });
    _compositeSubscription.add(sub);

    // React on toolbar buttons
    sub = widget.mapView.onToolbarAction.listen((id) {
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
      _setLocation(new models.Location(
          description: "Marker Position",
          latitude: _positionMarker.latitude,
          longitude: _positionMarker.longitude));
    }
    widget.mapView.dismiss();
    _compositeSubscription.cancel();
  }

  _setLocation(models.Location location) {
    setState(() {
      this.location = location;
      _textEditController.text = location.description;
    });
  }
}

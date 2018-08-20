import 'package:flutter/material.dart';

import 'package:map_view/map_view.dart';

import 'package:trufi_app/api/location_api.dart' as api;

import 'location_search_delegate.dart';

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
      this.onIconTap});

  final Key fieldKey;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;
  final StaticMapProvider staticMapProvider;
  final Function onIconTap;

  @override
  LocationFieldState createState() => new LocationFieldState();
}

class LocationFieldState extends State<LocationField> {
  final LocationSearchDelegate _delegate = new LocationSearchDelegate();
  final FocusNode _focusNode = new FocusNode();
  final TextEditingController _textEditController = new TextEditingController();

  CameraPosition cameraPosition;
  Uri staticMapUri;

  api.Location location;

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

  _showSearch() async {
    location = await showSearch(context: context, delegate: _delegate);
    setState(() {
      _textEditController.text = location?.description ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      key: widget.fieldKey,
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: _focusNode,
      controller: _textEditController,
      decoration: new InputDecoration(
        border: const UnderlineInputBorder(),
        filled: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: new GestureDetector(
          onTap: widget.onIconTap,
          child: new Icon(Icons.add_location),
        ),
      ),
    );
  }
}

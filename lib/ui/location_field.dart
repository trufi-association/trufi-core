import 'package:flutter/material.dart';

import 'package:map_view/map_view.dart';

import 'search_delegate.dart';

class LocationField extends StatefulWidget {
  const LocationField({
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.staticMapProvider,
    this.onIconTap
  });

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
  _LocationFieldState createState() => new _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {

  final SearchDemoSearchDelegate _delegate = new SearchDemoSearchDelegate();
  final FocusNode _focusNode = new FocusNode();

  CameraPosition cameraPosition;
  Uri staticMapUri;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange(){
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      showSearch(context: context, delegate: _delegate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      key: widget.fieldKey,
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: _focusNode,
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

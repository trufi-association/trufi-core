import 'package:flutter/material.dart';

import '../trufi_localizations.dart';

class SetDescriptionDialog extends StatefulWidget {
  final String initText;
  SetDescriptionDialog({this.initText = ""});
  @override
  _SetDescriptionDialogState createState() => _SetDescriptionDialogState();
}

class _SetDescriptionDialogState extends State<SetDescriptionDialog> {
  TextEditingController textController = TextEditingController();
  bool _hasInputError = true;

  @override
  void initState() {
    textController.text = widget.initText;
    _hasInputError = !_validateInput(widget.initText);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TrufiLocalization localization =
        TrufiLocalizations.of(context).localization;
    return SimpleDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      backgroundColor: theme.primaryColor,
      title: Text(
        localization.savedPlacesEnterNameTitle(),
        style: TextStyle(
          fontSize: 20,
          color: theme.primaryTextTheme.body2.color,
        ),
      ),
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(20),
          height: 35,
          child: TextField(
            style: theme.textTheme.body2,
            onChanged: (value) {
                _hasInputError = !_validateInput(value);
            },
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: theme.primaryColor)),
            ),
            controller: textController,
            maxLines: 1,
            autofocus: true,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
              color: theme.backgroundColor,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                localization.commonCancel(),
                style: theme.textTheme.body2,
              ),
            ),
            RaisedButton(
              color: theme.backgroundColor,
              onPressed: () {
                if (!_hasInputError) {
                  String description = textController.text.trim();
                  textController.clear();
                  Navigator.of(context).pop(description);
                }
              },
              child: Text(
                localization.commonOK(),
                style: theme.textTheme.body2,
              ),
            ),
          ],
        )
      ],
    );
  }

  bool _validateInput(String text){
    return text.length > 0 && text.contains(RegExp(r"[a-zA-Z0-9]+"));
  }
}
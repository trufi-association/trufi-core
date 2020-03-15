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
    return AlertDialog(
      backgroundColor: theme.primaryColor,
      title: Text(
        localization.savedPlacesEnterNameTitle(),
        style: TextStyle(
          color: theme.primaryTextTheme.body2.color,
        ),
      ),
      content: Container(
        child: TextField(
          style: theme.primaryTextTheme.body2,
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.accentColor,
              )
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.backgroundColor,
              )
            ),
          ),
          onChanged: (value) {
              _hasInputError = !_validateInput(value);
          },
          controller: textController,
          maxLines: 1,
          autofocus: true,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          color: theme.primaryColor,
          textColor: theme.accentColor,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            localization.commonCancel().toUpperCase(),
          ),
        ),
        FlatButton(
          color: theme.primaryColor,
          textColor: theme.accentColor,
          onPressed: () {
            if (!_hasInputError) {
              String description = textController.text.trim();
              textController.clear();
              Navigator.of(context).pop(description);
            }
          },
          child: Text(
            localization.commonSave().toUpperCase(),
          ),
        ),
      ],
    );
  }

  bool _validateInput(String text){
    return text.length > 0 && text.contains(RegExp(r"[a-zA-Z0-9]+"));
  }
}
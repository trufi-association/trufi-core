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
    final onSave = () {
      if (!_hasInputError) {
        String description = textController.text.trim();
        textController.clear();
        Navigator.of(context).pop(description);
      }
    };
    return AlertDialog(
      title: Text(
        localization.savedPlacesEnterNameTitle(),
      ),
      content: Container(
        child: TextField(
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.accentColor,
              )
            ),
          ),
          onChanged: (value) {
              _hasInputError = !_validateInput(value);
          },
          onEditingComplete: onSave,
          controller: textController,
          maxLines: 1,
          autofocus: true,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          textColor: theme.accentColor,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            localization.commonCancel().toUpperCase(),
          ),
        ),
        FlatButton(
          textColor: theme.accentColor,
          onPressed: onSave,
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
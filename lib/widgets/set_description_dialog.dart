import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

class SetDescriptionDialog extends StatefulWidget {
  final String initText;

  const SetDescriptionDialog({this.initText = "", Key key}) : super(key: key);

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

  void onSave() {
    if (!_hasInputError) {
      final String description = textController.text.trim();
      textController.clear();
      Navigator.of(context).pop(description);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TrufiLocalization localization = TrufiLocalization.of(context);
    return AlertDialog(
      title: Text(
        localization.savedPlacesEnterNameTitle,
      ),
      content: TextField(
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: theme.accentColor,
          )),
        ),
        onChanged: (value) {
          _hasInputError = !_validateInput(value);
        },
        onEditingComplete: onSave,
        controller: textController,
        autofocus: true,
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: TextStyle(color: theme.accentColor),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            localization.commonCancel.toUpperCase(),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: TextStyle(color: theme.accentColor),
          ),
          onPressed: onSave,
          child: Text(
            localization.commonSave.toUpperCase(),
          ),
        ),
      ],
    );
  }

  bool _validateInput(String text) {
    return text.isNotEmpty && text.contains(RegExp("[a-zA-Z0-9]+"));
  }
}

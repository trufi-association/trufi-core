import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

class DialogEditText extends StatefulWidget {
  final String initText;

  const DialogEditText({this.initText = "", Key key}) : super(key: key);

  @override
  _DialogEditTextState createState() => _DialogEditTextState();
}

class _DialogEditTextState extends State<DialogEditText> {
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
        style: theme.textTheme.bodyText1,
      ),
      content: TextField(
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: theme.accentColor,
            ),
          ),
        ),
        style: theme.textTheme.bodyText1,
        onChanged: (value) {
          _hasInputError = !_validateInput(value);
        },
        onEditingComplete: onSave,
        controller: textController,
        autofocus: true,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            localization.commonCancel.toUpperCase(),
            style: TextStyle(color: theme.primaryColor),
          ),
        ),
        TextButton(
          onPressed: onSave,
          child: Text(
            localization.commonSave.toUpperCase(),
            style: TextStyle(color: theme.primaryColor),
          ),
        ),
      ],
    );
  }

  bool _validateInput(String text) {
    return text.isNotEmpty && text.contains(RegExp("[a-zA-Z0-9]+"));
  }
}

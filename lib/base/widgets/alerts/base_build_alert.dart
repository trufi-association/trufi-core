import 'package:flutter/material.dart';

import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class BaseBuildAlert extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget>? actions;

  const BaseBuildAlert({
    Key? key,
    required this.title,
    required this.content,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: title,
      titleTextStyle: TextStyle(
        color: theme.colorScheme.secondary,
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
      content: content,
      actions: actions,
    );
  }
}

class OKButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const OKButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      child: Text(
        localization.commonOK,
        style: TextStyle(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

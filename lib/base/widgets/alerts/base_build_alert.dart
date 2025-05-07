import 'package:flutter/material.dart';

import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class BaseBuildAlert extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget>? actions;

  const BaseBuildAlert({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

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
    super.key,
    this.onPressed,
  });

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

class CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CancelButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      child: Text(
        localization.commonCancel,
        style: TextStyle(
          color: theme.textTheme.displayMedium?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

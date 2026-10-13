import 'package:flutter/material.dart';

/// Dialog asking for a route name, pre-filled with [initialName].
///
/// The whole text starts selected so typing replaces the "A → B" default.
/// Every label is injected: `trufi_core_home_screen` reuses the dialog to
/// save a route with its own localizations, and must not depend on this
/// package's delegate being installed in the host app.
class RouteNameDialog extends StatefulWidget {
  const RouteNameDialog({
    super.key,
    required this.title,
    required this.initialName,
    required this.fieldLabel,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  final String title;
  final String initialName;
  final String fieldLabel;
  final String cancelLabel;
  final String confirmLabel;

  /// Shows the dialog. Resolves to the trimmed name, or null when cancelled.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String initialName,
    required String fieldLabel,
    required String cancelLabel,
    required String confirmLabel,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => RouteNameDialog(
        title: title,
        initialName: initialName,
        fieldLabel: fieldLabel,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
      ),
    );
  }

  @override
  State<RouteNameDialog> createState() => _RouteNameDialogState();
}

class _RouteNameDialogState extends State<RouteNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName)
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.initialName.length,
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextFormField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: widget.fieldLabel,
          border: const OutlineInputBorder(),
        ),
        onFieldSubmitted: (_) => _confirm(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => FilledButton(
            onPressed: value.text.trim().isEmpty ? null : _confirm,
            child: Text(widget.confirmLabel),
          ),
        ),
      ],
    );
  }
}

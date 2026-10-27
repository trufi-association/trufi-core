import 'package:flutter/material.dart';

/// Sheet asking for a route name, pre-filled with [initialName].
///
/// Same anatomy as the edit-place sheet (`EditPlaceDialog`): modal bottom
/// sheet with a drag handle, a title row closed by an X, a filled text
/// field and a full-width save button that follows the keyboard.
/// The whole text starts selected so typing replaces the "A → B" default.
/// Every label is injected: `trufi_core_home_screen` reuses the sheet to
/// save a route with its own localizations, and must not depend on this
/// package's delegate being installed in the host app. [cancelLabel] is
/// the tooltip of the close button.
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

  /// Shows the sheet. Resolves to the trimmed name, or null when dismissed.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String initialName,
    required String fieldLabel,
    required String cancelLabel,
    required String confirmLabel,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(colorScheme),
            _buildHeader(theme),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameField(colorScheme),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 8, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: widget.cancelLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _controller,
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: widget.fieldLabel,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        prefixIcon: const Icon(Icons.label_outline),
      ),
      onFieldSubmitted: (_) => _confirm(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) => FilledButton.icon(
          onPressed: value.text.trim().isEmpty ? null : _confirm,
          icon: const Icon(Icons.check),
          label: Text(
            widget.confirmLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

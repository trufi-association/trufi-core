import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class DialogUtils {
  /// Displays a custom modal dialog with advanced configuration options.
  /// The [builder] parameter defines the content of the modal.
  /// Other parameters control the appearance and behavior of the standard `showDialog` widget.
  static Future<T?> showAdvancedDialog<T>(
    BuildContext buildContext, {
    required WidgetBuilder builder,
    // showDialog params
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useRootNavigator = true,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) async =>
      showDialog<T?>(
        context: buildContext,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
        useRootNavigator: useRootNavigator,
        traversalEdgeBehavior: traversalEdgeBehavior,
        builder: builder,
      );
}

class BaseModalDialog extends StatelessWidget {
  const BaseModalDialog({
    super.key,
    required this.title,
    this.textError,
    this.infoButtonText,
    this.contentBuilder,
    this.actionsBuilder,
    this.leftActionsBuilder,
    this.width = 630,
    this.height,
    this.color,
    this.isLoading = false,
    this.hideCloseButton = false,
  });

  /// Creates a small-sized modal popup.
  /// The [title] parameter specifies the title of the popup.
  /// Other parameters allow customization of content, actions, and appearance.
  factory BaseModalDialog.small({
    required String title,
    String? textError,
    String? infoButtonText,
    WidgetBuilder? contentBuilder,
    WidgetBuilder? actionsBuilder,
    WidgetBuilder? leftActionsBuilder,
    Color? color,
    bool isLoading = false,
    bool hideCloseButton = false,
  }) =>
      BaseModalDialog(
        title: title,
        textError: textError,
        infoButtonText: infoButtonText,
        contentBuilder: contentBuilder,
        actionsBuilder: actionsBuilder,
        leftActionsBuilder: leftActionsBuilder,
        width: sizeWidthSmall,
        color: color,
        isLoading: isLoading,
        hideCloseButton: hideCloseButton,
      );

  /// Creates a medium-sized modal popup.
  /// The [title] parameter specifies the title of the popup.
  /// Other parameters allow customization of content, actions, and appearance.
  factory BaseModalDialog.medium({
    required String title,
    String? textError,
    String? infoButtonText,
    WidgetBuilder? contentBuilder,
    WidgetBuilder? actionsBuilder,
    WidgetBuilder? leftActionsBuilder,
    Color? color,
    bool isLoading = false,
    bool hideCloseButton = false,
  }) =>
      BaseModalDialog(
        title: title,
        textError: textError,
        infoButtonText: infoButtonText,
        contentBuilder: contentBuilder,
        actionsBuilder: actionsBuilder,
        leftActionsBuilder: leftActionsBuilder,
        width: sizeWidthMedium,
        color: color,
        isLoading: isLoading,
        hideCloseButton: hideCloseButton,
      );

  /// Creates a big-sized modal popup.
  /// The [title] parameter specifies the title of the popup.
  /// Other parameters allow customization of content, actions, and appearance.
  factory BaseModalDialog.big({
    required String title,
    String? textError,
    String? infoButtonText,
    WidgetBuilder? contentBuilder,
    WidgetBuilder? actionsBuilder,
    WidgetBuilder? leftActionsBuilder,
    Color? color,
    bool isLoading = false,
    bool hideCloseButton = false,
  }) =>
      BaseModalDialog(
        title: title,
        textError: textError,
        infoButtonText: infoButtonText,
        contentBuilder: contentBuilder,
        actionsBuilder: actionsBuilder,
        leftActionsBuilder: leftActionsBuilder,
        width: sizeWidthBig,
        color: color,
        isLoading: isLoading,
        hideCloseButton: hideCloseButton,
      );

  static const sizeWidthSmall = 500.0;
  static const sizeWidthMedium = 700.0;
  static const sizeWidthBig = 1000.0;

  final String title;
  final String? textError;
  final String? infoButtonText;
  final WidgetBuilder? contentBuilder;
  final WidgetBuilder? actionsBuilder;
  final WidgetBuilder? leftActionsBuilder;
  final double width;
  final double? height;
  final Color? color;
  final bool isLoading;
  final bool hideCloseButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentWidget = Container(
      margin: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: actionsBuilder != null ? 0 : 24,
        top: 2,
      ),
      child: contentBuilder?.call(context),
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: kIsWeb
              ? null
              : const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          width: width,
          height: height,
          constraints: const BoxConstraints(
            minHeight: 200,
            maxHeight: 800,
          ),
          decoration: BoxDecoration(
            color: color ?? theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withAlpha((0.2 * 255).round())
                    : Colors.black.withAlpha((0.2 * 255).round()),
                offset: const Offset(0, 4),
                blurRadius: 20,
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 16,
                  top: 8,
                  bottom: 20,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          title,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (!hideCloseButton)
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.close),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Flexible(child: contentWidget),
              if (isLoading)
                Container(
                  margin: const EdgeInsets.only(top: 6, bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const SizedBox(height: 4),
                ),
              if (actionsBuilder != null)
                Container(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    6,
                    24,
                    infoButtonText == null ? 12 : 6,
                  ),
                  child: Column(
                    children: [
                      if (textError != null)
                        Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            alignment: Alignment.centerRight,
                            child: Text(
                              textError!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (leftActionsBuilder != null) ...[
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: leftActionsBuilder!(context),
                            ),
                            const Spacer(),
                          ],
                          actionsBuilder!(context),
                        ],
                      ),
                    ],
                  ),
                ),
              if (infoButtonText != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 12),
                  alignment: Alignment.center,
                  child: Text(
                    infoButtonText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

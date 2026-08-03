import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/transport_list_localizations.dart';

/// Shows a scannable QR code that opens the app on the routes list
/// filtered to [operatorName] (see the `operator` deep-link parameter).
///
/// [link] is what gets encoded, displayed, copied, and shared — operators
/// print the QR (or share the link) to place it in vehicles and at stops.
Future<void> showOperatorQrDialog(
  BuildContext context, {
  required String operatorName,
  required String link,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) =>
        _OperatorQrDialog(operatorName: operatorName, link: link),
  );
}

class _OperatorQrDialog extends StatefulWidget {
  final String operatorName;
  final String link;

  const _OperatorQrDialog({required this.operatorName, required this.link});

  @override
  State<_OperatorQrDialog> createState() => _OperatorQrDialogState();
}

class _OperatorQrDialogState extends State<_OperatorQrDialog> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final materialLocalizations = MaterialLocalizations.of(context);
    final localization = TransportListLocalizations.of(context);
    // The QR always sits on the white card below; brand it with the
    // primary color when it is dark enough to stay scannable, otherwise
    // fall back to near-black.
    final qrColor = scheme.primary.computeLuminance() < 0.35
        ? scheme.primary
        : const Color(0xFF1F1F1F);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        // Scroll on short viewports (small phones, landscape) instead of
        // overflowing the dialog.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tinted header: operator identity + what this dialog is for.
              Container(
                width: double.infinity,
                color: scheme.surfaceContainerHighest,
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(
                        Icons.business_rounded,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.operatorName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            localization.qrShareSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: materialLocalizations.closeButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // White backdrop and generous quiet zone so the code stays
                    // scannable when printed or shown in dark mode. The
                    // fixed-size SizedBox is required: QrImageView uses a
                    // LayoutBuilder, which cannot answer intrinsic-dimension
                    // queries made inside dialogs.
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: SizedBox(
                        width: 208,
                        height: 208,
                        child: QrImageView(
                          data: widget.link,
                          version: QrVersions.auto,
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                          backgroundColor: Colors.white,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: qrColor,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: qrColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // The canonical link, selectable for manual sharing.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.link_rounded,
                            size: 16,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: SelectableText(
                              widget.link,
                              maxLines: 1,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.share_rounded),
                        label: Text(materialLocalizations.shareButtonLabel),
                        style: FilledButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(text: widget.link),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton.icon(
                        icon: Icon(
                          _copied ? Icons.check_rounded : Icons.copy_rounded,
                        ),
                        label: Text(materialLocalizations.copyButtonLabel),
                        style: TextButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: widget.link),
                          );
                          if (mounted) setState(() => _copied = true);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

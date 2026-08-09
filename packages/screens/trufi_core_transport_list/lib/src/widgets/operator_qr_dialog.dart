import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart';

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
  return showTrufiModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _OperatorQrSheet(operatorName: operatorName, link: link),
  );
}

class _OperatorQrSheet extends StatefulWidget {
  final String operatorName;
  final String link;

  const _OperatorQrSheet({required this.operatorName, required this.link});

  @override
  State<_OperatorQrSheet> createState() => _OperatorQrSheetState();
}

class _OperatorQrSheetState extends State<_OperatorQrSheet> {
  bool _linkCopied = false;
  bool _imageCopied = false;

  /// Renders the QR at print quality on a white background with a quiet
  /// zone, so the copied image scans as reliably as the on-screen one.
  Future<Uint8List> _qrPngBytes() async {
    const size = 768.0;
    // ~4 modules of quiet zone (QR spec) for a version-6-ish code.
    const margin = 80.0;
    final painter = QrPainter(
      data: widget.link,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, size, size),
      Paint()..color = Colors.white,
    );
    canvas.translate(margin, margin);
    painter.paint(canvas, const Size(size - 2 * margin, size - 2 * margin));
    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final materialLocalizations = MaterialLocalizations.of(context);
    final l10n = TransportListLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header with operator name
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.operatorName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.qrShareSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  children: [
                    // White backdrop and generous quiet zone so the code
                    // stays scannable when printed or shown in dark mode.
                    // The fixed-size SizedBox is required: QrImageView uses
                    // a LayoutBuilder, which cannot answer the
                    // intrinsic-dimension queries made around it.
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: QrImageView(
                          data: widget.link,
                          version: QrVersions.auto,
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // The canonical link with an inline copy affordance.
                    Container(
                      padding: const EdgeInsets.only(left: 14, right: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              widget.link,
                              maxLines: 1,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: materialLocalizations.copyButtonLabel,
                            icon: Icon(
                              _linkCopied
                                  ? Icons.check_rounded
                                  : Icons.copy_rounded,
                              size: 20,
                              color: _linkCopied
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              await Clipboard.setData(
                                ClipboardData(text: widget.link),
                              );
                              if (mounted) {
                                setState(() => _linkCopied = true);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Actions: copy the QR image / share the link
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final bytes = await _qrPngBytes();
                        await Pasteboard.writeImage(bytes);
                        if (mounted) setState(() => _imageCopied = true);
                      } catch (e) {
                        // Most likely a host app missing the FileProvider
                        // setup (see package README) — fail visibly, not
                        // with an unhandled PlatformException.
                        debugPrint('OperatorQrSheet: copy image failed: $e');
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.copyQrImageFailed)),
                        );
                      }
                    },
                    icon: Icon(
                      _imageCopied
                          ? Icons.check_rounded
                          : Icons.qr_code_rounded,
                      size: 20,
                    ),
                    label: Text(l10n.copyQrImage),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      // Share as a URI so messengers linkify it — sharing
                      // an http(s) link as plain text leaves the receiver
                      // with an untappable string (#953).
                      final uri = Uri.tryParse(widget.link);
                      SharePlus.instance.share(
                        uri != null && uri.hasScheme && uri.scheme.startsWith('http')
                            ? ShareParams(uri: uri)
                            : ShareParams(text: widget.link),
                      );
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: Text(materialLocalizations.shareButtonLabel),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

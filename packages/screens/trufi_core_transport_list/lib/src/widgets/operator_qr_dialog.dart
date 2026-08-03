import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _copied = false;

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
                    // The canonical link, selectable for manual sharing.
                    SelectableText(
                      widget.link,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await Clipboard.setData(
                          ClipboardData(text: widget.link),
                        );
                        if (mounted) setState(() => _copied = true);
                      },
                      icon: Icon(
                        _copied ? Icons.check_rounded : Icons.copy_rounded,
                        size: 20,
                      ),
                      label: Text(materialLocalizations.copyButtonLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Share button
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  SharePlus.instance.share(ShareParams(text: widget.link));
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
          ),
        ],
      ),
    );
  }
}

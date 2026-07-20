import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

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
    final materialLocalizations = MaterialLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.business_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.operatorName,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // White backdrop and generous quiet zone so the code stays
          // scannable when printed or shown in dark mode. The fixed-size
          // SizedBox is required: QrImageView uses a LayoutBuilder, which
          // cannot answer the intrinsic-dimension queries AlertDialog
          // makes of its content.
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: 220,
              height: 220,
              child: QrImageView(
                data: widget.link,
                version: QrVersions.auto,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            widget.link,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded),
          label: Text(materialLocalizations.copyButtonLabel),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: widget.link));
            if (mounted) setState(() => _copied = true);
          },
        ),
        FilledButton.icon(
          icon: const Icon(Icons.share_rounded),
          label: Text(materialLocalizations.shareButtonLabel),
          onPressed: () {
            SharePlus.instance.share(ShareParams(text: widget.link));
          },
        ),
      ],
    );
  }
}

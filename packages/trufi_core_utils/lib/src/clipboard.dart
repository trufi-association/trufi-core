import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// How long the "copied" confirmation stays on screen.
const Duration copyConfirmationDuration = Duration(milliseconds: 1500);

/// Copies [text] to the system clipboard and confirms it to the user with a
/// light haptic tick and a short floating [SnackBar] reading [confirmation].
///
/// Shared behaviour behind "long-press a place or stop name to copy it"
/// (trufi-sanaa#9). Every surface passes its own localized [confirmation]
/// because this package carries no localizations.
///
/// `Clipboard.setData` is issued synchronously, before the first `await`, so
/// on the web the write still happens inside the user-gesture context: Safari
/// rejects clipboard writes that run after the gesture callback has yielded
/// (flutter/flutter#106046). Keep that order when editing.
///
/// Android 13+ additionally shows its own system confirmation on copy; iOS
/// and the web show nothing, which is why the SnackBar stays. When the write
/// fails nothing is shown.
Future<void> copyToClipboard(
  BuildContext context,
  String text, {
  required String confirmation,
  Duration duration = copyConfirmationDuration,
}) async {
  final write = Clipboard.setData(ClipboardData(text: text));
  HapticFeedback.lightImpact();
  // Resolved before awaiting: the context may be gone afterwards.
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    await write;
  } catch (_) {
    return;
  }
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(confirmation),
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

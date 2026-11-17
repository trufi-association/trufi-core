import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart' show LocationService;

import '../../../l10n/transport_list_localizations.dart';
import '../nearby_lines_cubit.dart';

/// Tells the rider why "use my location" found no position (trufi-app#78).
///
/// The two causes the app cannot ask its way out of get the home screen's
/// dialogs, with a shortcut to the settings that fix them: a permission
/// denied for good (the system no longer shows its prompt) opens the app's
/// settings page, location switched off opens the device's location
/// settings. The two the rider can simply retry — the prompt was just
/// answered "don't allow", or no fix arrived — get a snack bar.
///
/// [canOpenSettings] is false where the platform has no such pages: on web
/// geolocator's `openAppSettings` / `openLocationSettings` throw an
/// `UnsupportedError`, so the dialog only explains.
void showNearbyLocateFailure(
  BuildContext context,
  NearbyLocateFailure failure, {
  required LocationService locationService,
  bool canOpenSettings = !kIsWeb,
}) {
  final l10n = TransportListLocalizations.of(context);
  switch (failure) {
    case NearbyLocateFailure.permissionDeniedForever:
      _showSettingsDialog(
        context,
        icon: Icons.location_off_rounded,
        title: l10n.nearbyLocationPermissionTitle,
        message: l10n.nearbyLocationPermissionDeniedForever,
        openSettings: canOpenSettings ? locationService.openAppSettings : null,
      );
    case NearbyLocateFailure.serviceDisabled:
      _showSettingsDialog(
        context,
        icon: Icons.location_disabled_rounded,
        title: l10n.nearbyLocationDisabledTitle,
        message: l10n.nearbyLocationDisabledMessage,
        openSettings: canOpenSettings
            ? locationService.openLocationSettings
            : null,
      );
    case NearbyLocateFailure.permissionDenied:
      _showMessage(context, l10n.nearbyLocationPermissionDenied);
    case NearbyLocateFailure.noFix:
      _showMessage(context, l10n.nearbyLocationNoFix);
  }
}

/// The home screen's location dialog: an error-tinted glyph beside the
/// title, the explanation, "Cancel" and "Open settings". Without
/// [openSettings] there is nothing to cancel: a single "Close".
///
/// Title and message scroll: with a large font size on a small phone the
/// message is taller than the room above the buttons, and a dialog that
/// does not scroll cuts it there with no way to read the rest.
void _showSettingsDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required Future<bool> Function()? openSettings,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final l10n = TransportListLocalizations.of(context);
  final material = MaterialLocalizations.of(context);

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          Icon(icon, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        if (openSettings == null)
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(material.closeButtonLabel),
          )
        else ...[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(material.cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _open(openSettings);
            },
            child: Text(l10n.nearbyLocationOpenSettings),
          ),
        ],
      ],
    ),
  );
}

/// A settings page that cannot be opened is not worth an error: the
/// dialog already said what to enable.
Future<void> _open(Future<bool> Function() openSettings) async {
  try {
    await openSettings();
  } catch (_) {
    // No such page on this platform, or the plugin failed.
  }
}

/// A floating snack bar, like the one for a line whose detail cannot be
/// opened; long enough to read two sentences.
void _showMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Builder for the privacy consent overlay widget.
///
/// The [onAccept] callback should be called when user accepts.
/// The [onDecline] callback should be called when user declines.
typedef PrivacyConsentOverlayBuilder = Widget Function(
  VoidCallback onAccept,
  VoidCallback onDecline,
);

/// Manages the privacy consent state for log reporting.
///
/// The overlay is pushed to the stack when the app is ready.
/// If other overlays (like onboarding) are also pushed, they will stack
/// and show in order - the top overlay is visible, when popped the next shows.
///
/// Example usage:
/// ```dart
/// PrivacyConsentManager(
///   overlayBuilder: (onAccept, onDecline) => PrivacyConsentSheet(
///     onAccept: onAccept,
///     onDecline: onDecline,
///   ),
/// )
/// ```
class PrivacyConsentManager extends AppOverlayManager {
  static const _consentAcceptedKey = 'trufi_privacy_consent_accepted';
  static const _consentShownKey = 'trufi_privacy_consent_shown';
  static const _overlayId = 'privacy_consent';

  /// Builder for the privacy consent overlay widget.
  /// If null, no overlay will be shown automatically.
  final PrivacyConsentOverlayBuilder? overlayBuilder;

  OverlayService? _overlayService;
  bool _isLoading = true;
  bool _isAccepted = false;
  bool _wasShown = false;

  PrivacyConsentManager({this.overlayBuilder});

  @override
  bool get isLoading => _isLoading;

  /// Whether privacy consent has been accepted
  bool get isAccepted => _isAccepted;

  /// Whether the consent dialog was already shown (user may have declined)
  bool get wasShown => _wasShown;

  /// Whether consent needs to be shown (not yet shown to user)
  bool get needsConsent => !_isLoading && !_wasShown;

  @override
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _isAccepted = prefs.getBool(_consentAcceptedKey) ?? false;
    _wasShown = prefs.getBool(_consentShownKey) ?? false;

    _isLoading = false;
    notifyListeners();
  }

  @override
  void onAppReady(OverlayService overlayService) {
    _overlayService = overlayService;
    _pushOverlayIfNeeded();
  }

  void _pushOverlayIfNeeded() {
    if (needsConsent &&
        overlayBuilder != null &&
        _overlayService != null &&
        !_overlayService!.hasOverlayWithId(_overlayId)) {
      _overlayService!.pushOverlay(
        child: overlayBuilder!(_onAccept, _onDecline),
        id: _overlayId,
      );
    }
  }

  void _onAccept() {
    acceptConsent();
    _overlayService?.popOverlayById(_overlayId);
  }

  void _onDecline() {
    declineConsent();
    _overlayService?.popOverlayById(_overlayId);
  }

  /// Marks consent as accepted (user opted in)
  Future<void> acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentAcceptedKey, true);
    await prefs.setBool(_consentShownKey, true);
    _isAccepted = true;
    _wasShown = true;
    notifyListeners();
  }

  /// Marks consent as declined (user opted out, but dialog was shown)
  Future<void> declineConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentAcceptedKey, false);
    await prefs.setBool(_consentShownKey, true);
    _isAccepted = false;
    _wasShown = true;
    notifyListeners();
  }

  /// Resets consent state (useful for testing)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consentAcceptedKey);
    await prefs.remove(_consentShownKey);
    _isAccepted = false;
    _wasShown = false;
    notifyListeners();
    _pushOverlayIfNeeded();
  }
}

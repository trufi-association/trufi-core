import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Builder for the onboarding overlay widget.
///
/// The [onComplete] callback should be called when onboarding is finished.
typedef OnboardingOverlayBuilder = Widget Function(VoidCallback onComplete);

/// Manages the onboarding completion state.
///
/// Example usage:
/// ```dart
/// OnboardingManager(
///   overlayBuilder: (onComplete) => OnboardingSheet(onComplete: onComplete),
/// )
/// ```
class OnboardingManager extends AppOverlayManager {
  static const _onboardingCompletedKey = 'trufi_onboarding_completed';
  static const _overlayId = 'onboarding';

  /// Builder for the onboarding overlay widget.
  /// If null, no overlay will be shown automatically.
  final OnboardingOverlayBuilder? overlayBuilder;

  OverlayService? _overlayService;
  bool _isLoading = true;
  bool _isCompleted = false;

  OnboardingManager({this.overlayBuilder});

  @override
  bool get isLoading => _isLoading;

  /// Whether onboarding has been completed
  bool get isCompleted => _isCompleted;

  /// Whether onboarding needs to be shown
  bool get needsOnboarding => !_isLoading && !_isCompleted;

  @override
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _isCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;

    _isLoading = false;
    notifyListeners();
  }

  @override
  void onAppReady(OverlayService overlayService) {
    _overlayService = overlayService;
    _checkAndPushOverlay();
  }

  void _checkAndPushOverlay() {
    if (needsOnboarding &&
        overlayBuilder != null &&
        _overlayService != null &&
        !_overlayService!.hasOverlayWithId(_overlayId)) {
      _overlayService!.pushOverlay(
        child: overlayBuilder!(_onOverlayComplete),
        id: _overlayId,
      );
    }
  }

  void _onOverlayComplete() {
    markCompleted();
    _overlayService?.popOverlayById(_overlayId);
  }

  /// Marks onboarding as completed
  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    _isCompleted = true;
    notifyListeners();
  }

  /// Resets onboarding state (useful for testing)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
    _isCompleted = false;
    notifyListeners();
    // Re-check if we need to show overlay
    _checkAndPushOverlay();
  }
}

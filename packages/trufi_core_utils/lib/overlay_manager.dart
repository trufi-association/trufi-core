import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Type of overlay display
enum OverlayType {
  /// Full screen overlay with semi-transparent background
  fullScreen,

  /// Bottom sheet style overlay
  bottomSheet,

  /// Top notification banner
  topBanner,

  /// Bottom notification banner
  bottomBanner,

  /// Custom positioned overlay
  custom,
}

/// Configuration for an overlay entry
class OverlayConfig {
  /// Type of overlay display
  final OverlayType type;

  /// Whether tapping outside dismisses the overlay
  final bool dismissible;

  /// Background color (for fullScreen type)
  final Color? barrierColor;

  /// Animation duration
  final Duration animationDuration;

  /// Unique identifier for this overlay
  final String? id;

  const OverlayConfig({
    this.type = OverlayType.fullScreen,
    this.dismissible = false,
    this.barrierColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.id,
  });

  /// Full screen overlay config
  static const fullScreen = OverlayConfig(type: OverlayType.fullScreen);

  /// Bottom sheet overlay config
  static const bottomSheet = OverlayConfig(type: OverlayType.bottomSheet);

  /// Top banner notification config
  static const topBanner = OverlayConfig(
    type: OverlayType.topBanner,
    dismissible: true,
  );

  /// Bottom banner notification config
  static const bottomBanner = OverlayConfig(
    type: OverlayType.bottomBanner,
    dismissible: true,
  );
}

/// An entry in the overlay stack
class AppOverlayEntry {
  /// The widget to display
  final Widget child;

  /// Configuration for this overlay
  final OverlayConfig config;

  /// Unique key for this entry
  final UniqueKey key;

  AppOverlayEntry({
    required this.child,
    this.config = const OverlayConfig(),
  }) : key = UniqueKey();
}

/// Manages a stack of overlay widgets and AppOverlayManagers.
///
/// Implements [OverlayService] so it can be passed to [AppOverlayManager]s.
///
/// Lifecycle:
/// 1. Create OverlayManager with list of AppOverlayManagers
/// 2. Call [initializeManagers] to init all managers (async)
/// 3. Call [notifyAppReady] when UI is ready so managers can push overlays
///
/// Example:
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => OverlayManager(
///     managers: [
///       OnboardingManager(...),
///       PrivacyConsentManager(...),
///     ],
///   ),
/// )
/// ```
class OverlayManager extends ChangeNotifier implements OverlayService {
  final List<AppOverlayEntry> _overlays = [];
  final List<AppOverlayManager> _managers;

  OverlayManager({List<AppOverlayManager> managers = const []})
      : _managers = managers;

  /// The registered AppOverlayManagers
  List<AppOverlayManager> get managers =>
      List.unmodifiable(_managers);

  /// Get a manager by type.
  ///
  /// Returns null if no manager of the given type is registered.
  ///
  /// Example:
  /// ```dart
  /// final privacyManager = overlayManager.getManager<PrivacyConsentManager>();
  /// ```
  T? getManager<T extends AppOverlayManager>() {
    for (final manager in _managers) {
      if (manager is T) {
        return manager;
      }
    }
    return null;
  }

  /// Initialize all AppOverlayManagers asynchronously.
  Future<void> initializeManagers() async {
    for (final manager in _managers) {
      await manager.initialize();
    }
  }

  /// Notify all AppOverlayManagers that the app is ready.
  /// Managers can then push their overlays.
  void notifyAppReady() {
    for (final manager in _managers) {
      manager.onAppReady(this);
    }
  }

  /// Current list of overlays (read-only)
  List<AppOverlayEntry> get overlays => List.unmodifiable(_overlays);

  /// Whether there are any overlays showing
  bool get hasOverlays => _overlays.isNotEmpty;

  /// The current (top) overlay, if any
  AppOverlayEntry? get current => _overlays.isNotEmpty ? _overlays.last : null;

  /// Number of overlays in the stack
  int get count => _overlays.length;

  /// Push a new overlay onto the stack
  void push(AppOverlayEntry entry) {
    _overlays.add(entry);
    notifyListeners();
  }

  /// Push a widget with default config
  void pushWidget(Widget child, {OverlayConfig config = const OverlayConfig()}) {
    push(AppOverlayEntry(child: child, config: config));
  }

  /// Pop the top overlay from the stack
  void pop() {
    if (_overlays.isNotEmpty) {
      _overlays.removeLast();
      notifyListeners();
    }
  }

  /// Pop all overlays
  void clear() {
    if (_overlays.isNotEmpty) {
      _overlays.clear();
      notifyListeners();
    }
  }

  /// Pop overlay by id
  void popById(String id) {
    final index = _overlays.indexWhere((e) => e.config.id == id);
    if (index != -1) {
      _overlays.removeAt(index);
      notifyListeners();
    }
  }

  /// Check if an overlay with given id exists
  @override
  bool hasOverlayWithId(String id) {
    return _overlays.any((e) => e.config.id == id);
  }

  /// Replace top overlay with a new one
  void replace(AppOverlayEntry entry) {
    if (_overlays.isNotEmpty) {
      _overlays.removeLast();
    }
    _overlays.add(entry);
    notifyListeners();
  }

  // OverlayService implementation

  @override
  void pushOverlay({
    required Widget child,
    required String id,
    bool dismissible = false,
  }) {
    push(AppOverlayEntry(
      child: child,
      config: OverlayConfig(
        type: OverlayType.fullScreen,
        dismissible: dismissible,
        id: id,
      ),
    ));
  }

  @override
  void popOverlayById(String id) => popById(id);

  // Provider helpers
  static OverlayManager read(BuildContext context) =>
      context.read<OverlayManager>();
  static OverlayManager watch(BuildContext context) =>
      context.watch<OverlayManager>();
  static OverlayManager? maybeRead(BuildContext context) =>
      context.read<OverlayManager?>();
  static OverlayManager? maybeWatch(BuildContext context) =>
      context.watch<OverlayManager?>();
}

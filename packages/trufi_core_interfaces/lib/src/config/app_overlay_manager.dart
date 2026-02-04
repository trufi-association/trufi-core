import 'package:flutter/foundation.dart';

import '../overlay/overlay_service.dart';

/// Interface for app-level managers that can push overlays.
///
/// Managers implementing this interface will be:
/// 1. Automatically injected as providers by TrufiApp
/// 2. Initialized during the app initialization phase
/// 3. Called with [onAppReady] after the app UI is ready
/// 4. Available throughout the app via Provider
///
/// Example implementation:
/// ```dart
/// class MyCustomManager extends AppOverlayManager {
///   OverlayService? _overlayService;
///   Timer? _periodicTimer;
///   bool _isLoading = true;
///
///   @override
///   bool get isLoading => _isLoading;
///
///   @override
///   Future<void> initialize() async {
///     _isLoading = true;
///     notifyListeners();
///
///     // Load data from storage
///     await _loadFromStorage();
///
///     _isLoading = false;
///     notifyListeners();
///   }
///
///   @override
///   void onAppReady(OverlayService overlayService) {
///     _overlayService = overlayService;
///
///     // Push overlay if needed
///     if (needsToShowOverlay) {
///       _overlayService?.pushOverlay(
///         child: MyOverlayWidget(),
///         id: 'my_overlay',
///       );
///     }
///
///     // Setup periodic fetch if needed
///     _periodicTimer = Timer.periodic(Duration(minutes: 5), (_) {
///       _fetchData();
///     });
///   }
///
///   @override
///   void dispose() {
///     _periodicTimer?.cancel();
///     super.dispose();
///   }
/// }
/// ```
abstract class AppOverlayManager extends ChangeNotifier {
  /// Whether the manager is currently initializing.
  bool get isLoading;

  /// Initialize the manager asynchronously.
  ///
  /// This is called during the app initialization phase, before the main
  /// app UI is shown. Use this to load data from storage, APIs, etc.
  ///
  /// Implementations should:
  /// - Set [isLoading] to true at the start
  /// - Perform async operations (load from storage, etc.)
  /// - Set [isLoading] to false when complete
  /// - Call [notifyListeners] when state changes
  Future<void> initialize();

  /// Called when the app UI is ready and overlays can be shown.
  ///
  /// Use this to:
  /// - Push overlays based on manager state
  /// - Setup periodic fetch timers
  /// - Start background tasks
  ///
  /// The [overlayService] can be used to push/pop overlays.
  void onAppReady(OverlayService overlayService) {
    // Default implementation does nothing.
    // Override in subclasses to push overlays or setup timers.
  }
}

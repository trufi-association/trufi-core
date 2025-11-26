import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

/// Initialize the Trufi app with loading screen and error handling
/// 
/// Example:
/// ```dart
/// void main() {
///   initializeTrufiApp(
///     initialize: () async {
///       // Your async initialization code
///       await initializeDateFormatting('en');
///       await loadData();
///     },
///     onInitialized: (context) => const TrufiApp(),
///   );
/// }
/// ```
void initializeTrufiApp({
  required Future<void> Function() initialize,
  required Widget Function(BuildContext context) onInitialized,
  Widget Function(BuildContext context)? loadingWidget,
  Widget Function(BuildContext context, Exception error, VoidCallback retry)? errorWidget,
}) {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  runApp(
    _TrufiInitializationWrapper(
      initialize: initialize,
      onInitialized: onInitialized,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
    ),
  );
}

/// Wrapper widget that handles initialization states
class _TrufiInitializationWrapper extends StatefulWidget {
  const _TrufiInitializationWrapper({
    required this.initialize,
    required this.onInitialized,
    this.loadingWidget,
    this.errorWidget,
  });

  final Future<void> Function() initialize;
  final Widget Function(BuildContext context) onInitialized;
  final Widget Function(BuildContext context)? loadingWidget;
  final Widget Function(BuildContext context, Exception error, VoidCallback retry)? errorWidget;

  @override
  State<_TrufiInitializationWrapper> createState() => _TrufiInitializationWrapperState();
}

class _TrufiInitializationWrapperState extends State<_TrufiInitializationWrapper> {
  InitializationState _state = InitializationState.loading;
  Exception? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _state = InitializationState.loading;
      _error = null;
    });

    try {
      await widget.initialize();
      
      // Small delay to ensure loading screen is visible
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _state = InitializationState.success;
        });
      }
    } catch (e) {
      final error = e is Exception ? e : Exception(e.toString());
      debugPrint('Error initializing Trufi app: $e');

      if (mounted) {
        setState(() {
          _state = InitializationState.error;
          _error = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case InitializationState.loading:
        return widget.loadingWidget?.call(context) ?? const _DefaultLoadingScreen();
      
      case InitializationState.error:
        return widget.errorWidget?.call(context, _error!, _initialize) ??
            _ErrorScreen(
              error: _error!,
              onRetry: _initialize,
            );
      
      case InitializationState.success:
        return widget.onInitialized(context);
    }
  }
}

enum InitializationState {
  loading,
  error,
  success,
}

/// Default loading screen shown during initialization
class _DefaultLoadingScreen extends StatelessWidget {
  const _DefaultLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1E88E5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trufi logo placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus,
                  size: 64,
                  color: Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Trufi Transit',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error screen shown when initialization fails after all retries
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({
    required this.error,
    required this.onRetry,
  });

  final Exception error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFD32F2F),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFD32F2F),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Initialization Failed',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom loading screen builder
class TrufiLoadingScreen extends StatelessWidget {
  const TrufiLoadingScreen({
    super.key,
    this.appName = 'Trufi Transit',
    this.backgroundColor = const Color(0xFF1E88E5),
    this.logo,
    this.loadingText = 'Loading...',
  });

  final String appName;
  final Color backgroundColor;
  final Widget? logo;
  final String loadingText;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom logo or default
              logo ??
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      size: 64,
                      color: backgroundColor,
                    ),
                  ),
              const SizedBox(height: 32),
              Text(
                appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loadingText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

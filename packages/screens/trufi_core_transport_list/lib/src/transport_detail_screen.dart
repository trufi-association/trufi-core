import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart';

import '../l10n/transport_list_localizations.dart';
import 'models/transport_route.dart';

/// Callback type for moving the map to a specific location
typedef MapMoveCallback = void Function(double latitude, double longitude);

/// Callback type for selecting a stop on the map
typedef StopSelectionCallback = void Function(int? stopIndex);

/// Screen showing transport route details with map and stops
class TransportDetailScreen extends StatefulWidget {
  final String routeCode;
  final Future<TransportRouteDetails?> Function(String code) getRouteDetails;
  final Widget Function(
    BuildContext context,
    TransportRouteDetails? route,
    void Function(MapMoveCallback) registerMapMoveCallback,
    void Function(StopSelectionCallback) registerStopSelectionCallback,
  )? mapBuilder;
  final Uri? shareBaseUri;

  const TransportDetailScreen({
    super.key,
    required this.routeCode,
    required this.getRouteDetails,
    this.mapBuilder,
    this.shareBaseUri,
  });

  static Future<void> show(
    BuildContext context, {
    required String routeCode,
    required Future<TransportRouteDetails?> Function(String code)
        getRouteDetails,
    Widget Function(
      BuildContext context,
      TransportRouteDetails? route,
      void Function(MapMoveCallback) registerMapMoveCallback,
      void Function(StopSelectionCallback) registerStopSelectionCallback,
    )? mapBuilder,
    Uri? shareBaseUri,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TransportDetailScreen(
          routeCode: routeCode,
          getRouteDetails: getRouteDetails,
          mapBuilder: mapBuilder,
          shareBaseUri: shareBaseUri,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  State<TransportDetailScreen> createState() => _TransportDetailScreenState();
}

class _TransportDetailScreenState extends State<TransportDetailScreen>
    with SingleTickerProviderStateMixin {
  TransportRouteDetails? _route;
  bool _isLoading = true;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  late AnimationController _fadeController;
  MapMoveCallback? _mapMoveCallback;
  StopSelectionCallback? _stopSelectionCallback;
  int? _selectedStopIndex;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadRoute();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadRoute() async {
    setState(() => _isLoading = true);
    try {
      final route = await widget.getRouteDetails(widget.routeCode);
      if (mounted) {
        setState(() {
          _route = route;
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading route: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = TransportListLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, localization, theme, colorScheme),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    TransportListLocalizations localization,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // No AppBar - we'll use a custom header in the body
    return null;
  }

  Widget _buildTopBar(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final routeColor = _route?.backgroundColor ?? colorScheme.primary;
    final textColor = _route?.textColor ?? Colors.white;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Back button
              Material(
                color: colorScheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                shadowColor: Colors.black26,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: colorScheme.onSurface,
                      size: 22,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Route title card (only show when route is loaded)
              if (_route != null)
                Expanded(
                  child: Material(
                    color: colorScheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    elevation: 2,
                    shadowColor: Colors.black26,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          // Route badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: routeColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_route!.modeIcon != null) ...[
                                  IconTheme(
                                    data: IconThemeData(color: textColor, size: 16),
                                    child: _route!.modeIcon!,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  _route!.displayName,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Route name (show prefix like "MiniBus 1", origin/destination is in bottom sheet)
                          if (_route!.longNamePrefix.isNotEmpty)
                            Expanded(
                              child: Text(
                                _route!.longNamePrefix,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            const Spacer(),
                        ],
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),

              const SizedBox(width: 12),

              // Share button
              if (_route != null && widget.shareBaseUri != null)
                Material(
                  color: colorScheme.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  elevation: 2,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _shareRoute();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.share_rounded,
                        color: colorScheme.onSurface,
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Stack(
        children: [
          Positioned.fill(child: _LoadingState()),
          _buildBackButton(context, colorScheme),
        ],
      );
    }

    if (_route == null) {
      return Stack(
        children: [
          Positioned.fill(
            child: _ErrorState(onRetry: () => Navigator.pop(context)),
          ),
          _buildBackButton(context, colorScheme),
        ],
      );
    }

    return Stack(
      children: [
        // Map
        if (widget.mapBuilder != null)
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeController,
              child: widget.mapBuilder!(
                context,
                _route,
                (callback) => _mapMoveCallback = callback,
                (callback) => _stopSelectionCallback = callback,
              ),
            ),
          )
        else
          Positioned.fill(
            child: Container(
              color: colorScheme.surfaceContainerLow,
              child: Center(
                child: Icon(
                  Icons.map_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

        // Top bar with route info
        _buildTopBar(context, theme, colorScheme),

        // Bottom sheet with stops only
        TrufiBottomSheet(
          controller: _sheetController,
          initialChildSize: 0.35,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          snap: true,
          snapSizes: const [0.15, 0.35, 0.85],
          builder: (context, scrollController) => _StopsSheetContent(
            route: _route!,
            scrollController: scrollController,
            selectedStopIndex: _selectedStopIndex,
            onStopTap: (index, lat, lng) {
              HapticFeedback.selectionClick();
              setState(() => _selectedStopIndex = index);
              _mapMoveCallback?.call(lat, lng);
              _stopSelectionCallback?.call(index);
            },
          ),
        ),
      ],
    );
  }

  /// Simple back button for loading/error states
  Widget _buildBackButton(BuildContext context, ColorScheme colorScheme) {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            shadowColor: Colors.black26,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: colorScheme.onSurface,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _shareRoute() {
    if (_route == null || widget.shareBaseUri == null) return;
    final uri = widget.shareBaseUri!.replace(
      queryParameters: {'id': _route!.code},
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: $uri'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// Content for the stops bottom sheet
class _StopsSheetContent extends StatelessWidget {
  final TransportRouteDetails route;
  final ScrollController scrollController;
  final int? selectedStopIndex;
  final void Function(int index, double lat, double lng)? onStopTap;

  const _StopsSheetContent({
    required this.route,
    required this.scrollController,
    this.selectedStopIndex,
    this.onStopTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stops = route.stops ?? [];

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Origin/Destination header (Google Maps style)
        if (route.hasOriginDestination)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline indicators (green dot, dotted line, red dot)
                  Column(
                    children: [
                      // Green origin dot
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green.shade700,
                            width: 2,
                          ),
                        ),
                      ),
                      // Dotted line
                      CustomPaint(
                        size: const Size(2, 28),
                        painter: _DottedLinePainter(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      // Red destination dot
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red.shade700,
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Origin and destination text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Origin
                        Text(
                          route.longNameStart,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        // Destination
                        Text(
                          route.longNameLast,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Stops count header with divider
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stops.length} stops',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Divider(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Stops list
        if (stops.isEmpty)
          const SliverFillRemaining(
            child: _EmptyStopsInline(),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final stop = stops[index];
                final isFirst = index == 0;
                final isLast = index == stops.length - 1;
                final isSelected = selectedStopIndex == index;
                final routeColor = route.backgroundColor ?? colorScheme.primary;

                return _StopTimelineItem(
                  stop: stop,
                  isFirst: isFirst,
                  isLast: isLast,
                  isSelected: isSelected,
                  routeColor: routeColor,
                  onTap: onStopTap != null
                      ? () {
                          HapticFeedback.selectionClick();
                          onStopTap!(index, stop.latitude, stop.longitude);
                        }
                      : null,
                );
              },
              childCount: stops.length,
            ),
          ),
      ],
    );
  }
}

/// Inline empty stops state for sliver
class _EmptyStopsInline extends StatelessWidget {
  const _EmptyStopsInline();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: 48,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No stops available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Timeline stop item
class _StopTimelineItem extends StatelessWidget {
  final TransportStop stop;
  final bool isFirst;
  final bool isLast;
  final bool isSelected;
  final Color routeColor;
  final VoidCallback? onTap;

  const _StopTimelineItem({
    required this.stop,
    required this.isFirst,
    required this.isLast,
    this.isSelected = false,
    required this.routeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTerminal = isFirst || isLast;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? routeColor.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Timeline indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 16 : 12,
                  height: isSelected ? 16 : 12,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? routeColor
                        : (isTerminal ? routeColor : colorScheme.surface),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : routeColor,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: routeColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Stop name
                Expanded(
                  child: Text(
                    stop.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: (isTerminal || isSelected)
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected ? routeColor : null,
                    ),
                  ),
                ),
                // Selected indicator icon
                if (isSelected)
                  Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: routeColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading state with animated indicator
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading route...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state with retry option
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Route not found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The route could not be loaded',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Go back'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for dotted line between origin and destination
class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

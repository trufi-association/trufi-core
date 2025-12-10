import 'package:flutter/material.dart';

import '../l10n/transport_list_localizations.dart';
import 'models/transport_route.dart';
import 'widgets/transport_detail_sheet.dart';

/// Screen showing transport route details with map and stops
class TransportDetailScreen extends StatefulWidget {
  final String routeCode;
  final Future<TransportRouteDetails?> Function(String code) getRouteDetails;
  final Widget Function(BuildContext context, TransportRouteDetails? route)?
      mapBuilder;
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
    Widget Function(BuildContext context, TransportRouteDetails? route)?
        mapBuilder,
    Uri? shareBaseUri,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransportDetailScreen(
          routeCode: routeCode,
          getRouteDetails: getRouteDetails,
          mapBuilder: mapBuilder,
          shareBaseUri: shareBaseUri,
        ),
      ),
    );
  }

  @override
  State<TransportDetailScreen> createState() => _TransportDetailScreenState();
}

class _TransportDetailScreenState extends State<TransportDetailScreen> {
  TransportRouteDetails? _route;
  bool _isLoading = true;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _loadRoute();
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading route: $e')),
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
      appBar: AppBar(
        titleSpacing: 0,
        title: _route != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_route!.modeName != null)
                        Text(
                          '${_route!.modeName} - ',
                          style: theme.textTheme.titleMedium,
                        ),
                      Text(
                        _route!.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_route!.longNameFull.isNotEmpty)
                    Text(
                      _route!.longNameFull,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              )
            : null,
        actions: [
          if (_route != null && widget.shareBaseUri != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: localization.shareRoute,
              onPressed: _shareRoute,
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_route == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text('Route not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go back'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Map
        if (widget.mapBuilder != null)
          Positioned.fill(
            child: widget.mapBuilder!(context, _route),
          )
        else
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: const Center(
                child: Icon(Icons.map_outlined, size: 64),
              ),
            ),
          ),
        // Bottom sheet with stops
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.3,
          minChildSize: 0.1,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: TransportDetailSheet(
                      route: _route!,
                      onStopTap: (lat, lng) {
                        // Could trigger map movement here
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _shareRoute() {
    if (_route == null || widget.shareBaseUri == null) return;
    final uri = widget.shareBaseUri!.replace(
      queryParameters: {'id': _route!.code},
    );
    // Share functionality would be implemented by the consumer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share: $uri')),
    );
  }
}

import 'package:flutter/material.dart';

import '../l10n/transport_list_localizations.dart';
import 'models/transport_route.dart';
import 'transport_list_data_provider.dart';
import 'widgets/transport_tile.dart';

/// Main content widget for transport list
class TransportListContent extends StatefulWidget {
  final TransportListDataProvider dataProvider;
  final void Function(TransportRoute route) onRouteTap;
  final Widget Function(BuildContext context)? drawerBuilder;

  const TransportListContent({
    super.key,
    required this.dataProvider,
    required this.onRouteTap,
    this.drawerBuilder,
  });

  @override
  State<TransportListContent> createState() => _TransportListContentState();
}

class _TransportListContentState extends State<TransportListContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.dataProvider.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.dataProvider.load();
    });
  }

  @override
  void dispose() {
    widget.dataProvider.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = TransportListLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = widget.dataProvider.state;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: false,
          autocorrect: false,
          onChanged: (query) {
            widget.dataProvider.filter(query.trim().toLowerCase());
          },
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: localization.searchRoutes,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      widget.dataProvider.filter('');
                    },
                  )
                : null,
          ),
        ),
        actions: [
          if (!state.isLoading)
            IconButton(
              onPressed: () => widget.dataProvider.refresh(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
        ],
      ),
      drawer: widget.drawerBuilder?.call(context),
      body: _buildBody(context, state, localization),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TransportListState state,
    TransportListLocalizations localization,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.isLoading && state.filteredRoutes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.filteredRoutes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              localization.noRoutesFound,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => widget.dataProvider.refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.filteredRoutes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final route = state.filteredRoutes[index];
              return TransportTile(
                route: route,
                onTap: () => widget.onRouteTap(route),
              );
            },
          ),
        ),
        if (state.isLoading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
      ],
    );
  }
}

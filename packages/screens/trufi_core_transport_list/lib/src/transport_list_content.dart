import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/transport_list_localizations.dart';
import 'models/transport_route.dart';
import 'transport_list_data_provider.dart';
import 'widgets/transport_tile.dart';

/// Main content widget for transport list
class TransportListContent extends StatefulWidget {
  final TransportListDataProvider dataProvider;
  final void Function(TransportRoute route) onRouteTap;

  /// Whether to show the menu button. If true, will try to open the parent
  /// Scaffold's drawer when pressed.
  final bool showMenuButton;

  /// Called when the user dismisses the active operator/agency chip.
  /// Defaults to clearing the filter on [dataProvider]; hosts that mirror
  /// the filter elsewhere (e.g. the `operator` URL parameter) pass their
  /// own handler.
  final VoidCallback? onClearAgencyFilter;

  /// Called with an agency name when the user asks for its shareable QR
  /// code (button on each agency header and next to the active operator
  /// chip). When null the QR affordances are hidden.
  final void Function(String agencyName)? onShowOperatorQr;

  const TransportListContent({
    super.key,
    required this.dataProvider,
    required this.onRouteTap,
    this.showMenuButton = true,
    this.onClearAgencyFilter,
    this.onShowOperatorQr,
  });

  @override
  State<TransportListContent> createState() => _TransportListContentState();
}

class _TransportListContentState extends State<TransportListContent>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  late AnimationController _listAnimationController;
  bool _isSearchFocused = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    widget.dataProvider.addListener(_onDataChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  /// Initial fetch. `load` resets `filteredRoutes` to the full list, so
  /// re-scope it to any filter that was applied before/while loading
  /// (e.g. an `operator` deep-link filter set by the host screen).
  ///
  /// `load` implementations talk to the network/asset layer and can throw;
  /// without the catch the exception would be unhandled (the provider may
  /// be left in `isLoading`, showing an eternal shimmer with no feedback).
  Future<void> _initialLoad() async {
    try {
      await widget.dataProvider.load();
      widget.dataProvider.reapplyFilters();
      if (mounted && _loadFailed) setState(() => _loadFailed = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadFailed = true);
      _showLoadError(e);
    }
  }

  void _showLoadError(Object error) {
    // Keep the raw exception out of the UI; it still lands in the log for
    // debugging while users get the localized message only.
    debugPrint('TransportList: failed to load routes: $error');
    final localization = TransportListLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localization.errorLoadingRoutes)),
    );
  }

  @override
  void dispose() {
    widget.dataProvider.removeListener(_onDataChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
        _listAnimationController.forward(from: 0);
      }
    });
  }

  void _onSearchFocusChanged() {
    setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
  }

  /// Refresh the route list while preserving the active filters.
  /// Used by both the header refresh button and pull-to-refresh.
  ///
  /// `dataProvider.refresh()` re-fetches and resets `filteredRoutes` to all
  /// routes, which would visually contradict the still-populated search bar
  /// or an active operator chip. Re-applying keeps the user's intent and
  /// the filtered count consistent with the visible controls. Use the
  /// explicit clear (X) affordances to remove a filter.
  Future<void> _refreshKeepingFilter() async {
    try {
      await widget.dataProvider.refresh();
      widget.dataProvider.reapplyFilters();
      if (mounted && _loadFailed) setState(() => _loadFailed = false);
    } catch (e) {
      if (!mounted) return;
      // Keep showing the current list if we have one; only fall back to the
      // full-screen error state when there is nothing to show.
      if (widget.dataProvider.state.filteredRoutes.isEmpty) {
        setState(() => _loadFailed = true);
      }
      _showLoadError(e);
    }
  }

  /// Try to open the drawer from the nearest ancestor Scaffold
  void _tryOpenDrawer(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.hasDrawer ?? false) {
      scaffold!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = TransportListLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = widget.dataProvider.state;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Modern search header
            _SearchHeader(
              controller: _searchController,
              focusNode: _searchFocusNode,
              isFocused: _isSearchFocused,
              hintText: localization.searchRoutes,
              isLoading: state.isLoading,
              onChanged: (query) {
                widget.dataProvider.filter(query.trim().toLowerCase());
              },
              onClear: () {
                _searchController.clear();
                widget.dataProvider.filter('');
                _searchFocusNode.unfocus();
              },
              onRefresh: _refreshKeepingFilter,
              onMenuPressed: widget.showMenuButton
                  ? () {
                      HapticFeedback.lightImpact();
                      _tryOpenDrawer(context);
                    }
                  : null,
            ),

            // Active operator/agency filter (e.g. from a QR deep link)
            if (state.agencyFilter != null)
              _AgencyFilterChip(
                agencyName: state.agencyFilter!,
                onClear:
                    widget.onClearAgencyFilter ??
                    () => widget.dataProvider.setAgencyFilter(null),
                onShowQr: widget.onShowOperatorQr,
              ),

            // Route count indicator
            if (!state.isLoading && state.filteredRoutes.isNotEmpty)
              _RouteCountIndicator(
                count: state.filteredRoutes.length,
                isFiltered:
                    _searchController.text.isNotEmpty ||
                    state.agencyFilter != null,
              ),

            // Main content
            Expanded(child: _buildBody(context, state, localization)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TransportListState state,
    TransportListLocalizations localization,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Load failed and there is nothing cached to show: error + retry,
    // instead of the eternal shimmer a stuck `isLoading` would produce.
    if (_loadFailed && state.filteredRoutes.isEmpty) {
      return _LoadErrorState(
        message: localization.errorLoadingRoutes,
        retryLabel: localization.retry,
        onRetry: _initialLoad,
      );
    }

    // Loading state with shimmer
    if (state.isLoading && state.filteredRoutes.isEmpty) {
      return _ShimmerList();
    }

    // Empty state
    if (state.filteredRoutes.isEmpty) {
      return _EmptyState(
        message: localization.noRoutesFound,
        isSearch:
            _searchController.text.isNotEmpty || state.agencyFilter != null,
      );
    }

    // Build grouped list: agency headers + route tiles
    final listItems = _buildGroupedItems(
      state.filteredRoutes,
      _searchController.text.isNotEmpty,
      localization.otherAgencies,
    );

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshKeepingFilter,
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: listItems.length,
            itemBuilder: (context, index) {
              final item = listItems[index];

              // Staggered animation
              final animation = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _listAnimationController,
                  curve: Interval(
                    (index / listItems.length) * 0.5,
                    ((index + 1) / listItems.length) * 0.5 + 0.5,
                    curve: Curves.easeOutCubic,
                  ),
                ),
              );

              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - animation.value)),
                    child: Opacity(opacity: animation.value, child: child),
                  );
                },
                child: item.isHeader
                    ? _AgencyHeader(
                        name: item.headerName!,
                        routeCount: item.headerRouteCount!,
                        onQrTap:
                            item.headerAgency != null &&
                                widget.onShowOperatorQr != null
                            ? () => widget.onShowOperatorQr!(item.headerAgency!)
                            : null,
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TransportTile(
                          route: item.route!,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onRouteTap(item.route!);
                          },
                        ),
                      ),
              );
            },
          ),
        ),

        // Loading indicator overlay
        if (state.isLoading && state.filteredRoutes.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0),
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0),
                  ],
                ),
              ),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            ),
          ),
      ],
    );
  }

  /// Build a flat list of grouped items (agency headers + routes).
  /// When searching, skip headers for a flat filtered list.
  static List<_GroupedListItem> _buildGroupedItems(
    List<TransportRoute> routes,
    bool isSearching,
    String otherAgenciesLabel,
  ) {
    // During search, show flat list without headers
    if (isSearching) {
      return routes.map((r) => _GroupedListItem.route(r)).toList();
    }

    // Group routes by agency
    final grouped = <String, List<TransportRoute>>{};
    for (final route in routes) {
      final agency = route.agencyName ?? '';
      (grouped[agency] ??= []).add(route);
    }

    // Sort agencies alphabetically
    final sortedAgencies = grouped.keys.toList()..sort();

    final items = <_GroupedListItem>[];
    for (final agency in sortedAgencies) {
      final agencyRoutes = grouped[agency]!;
      items.add(
        _GroupedListItem.header(
          agency.isEmpty ? otherAgenciesLabel : agency,
          agencyRoutes.length,
          // Routes without an agency get a synthetic header — no real
          // operator to encode in a QR.
          agency: agency.isEmpty ? null : agency,
        ),
      );
      for (final route in agencyRoutes) {
        items.add(_GroupedListItem.route(route));
      }
    }
    return items;
  }
}

/// Item in the grouped list — either an agency header or a route tile.
class _GroupedListItem {
  final bool isHeader;
  final String? headerName;
  final int? headerRouteCount;
  final String? headerAgency;
  final TransportRoute? route;

  const _GroupedListItem._({
    required this.isHeader,
    this.headerName,
    this.headerRouteCount,
    this.headerAgency,
    this.route,
  });

  factory _GroupedListItem.header(String name, int count, {String? agency}) =>
      _GroupedListItem._(
        isHeader: true,
        headerName: name,
        headerRouteCount: count,
        headerAgency: agency,
      );

  factory _GroupedListItem.route(TransportRoute route) =>
      _GroupedListItem._(isHeader: false, route: route);
}

/// Agency section header widget.
class _AgencyHeader extends StatelessWidget {
  final String name;
  final int routeCount;

  /// Opens the shareable QR for this agency; hidden when null.
  final VoidCallback? onQrTap;

  const _AgencyHeader({
    required this.name,
    required this.routeCount,
    this.onQrTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.business_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (onQrTap != null)
            IconButton(
              icon: const Icon(Icons.qr_code_2_rounded, size: 20),
              color: colorScheme.onSurfaceVariant,
              visualDensity: VisualDensity.compact,
              tooltip: 'QR',
              onPressed: () {
                HapticFeedback.lightImpact();
                onQrTap!();
              },
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$routeCount',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern search header with Material 3 design
class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String hintText;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onRefresh;
  final VoidCallback? onMenuPressed;

  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.hintText,
    required this.isLoading,
    required this.onChanged,
    required this.onClear,
    required this.onRefresh,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Menu button
          if (onMenuPressed != null) ...[
            _MenuButton(onPressed: onMenuPressed!),
            const SizedBox(width: 12),
          ],

          // Search field
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isFocused
                      ? colorScheme.primary.withValues(alpha: 0.5)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: false,
                autocorrect: false,
                textInputAction: TextInputAction.search,
                onChanged: onChanged,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  prefixIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Icon(
                      Icons.search_rounded,
                      color: isFocused
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            onClear();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Refresh button
          const SizedBox(width: 12),
          _RefreshButton(
            isLoading: isLoading,
            onPressed: () {
              HapticFeedback.lightImpact();
              onRefresh();
            },
          ),
        ],
      ),
    );
  }
}

/// Animated refresh button
class _RefreshButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _RefreshButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimaryContainer,
                  ),
                )
              : Icon(
                  Icons.refresh_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
        ),
      ),
    );
  }
}

/// Chip showing the active operator/agency restriction with a clear
/// affordance. Shown when the list was opened via a QR/deep link like
/// `/routes?operator=...` or the filter was set programmatically.
class _AgencyFilterChip extends StatelessWidget {
  final String agencyName;
  final VoidCallback onClear;

  /// Opens the shareable QR for the active operator; hidden when null.
  final void Function(String agencyName)? onShowQr;

  const _AgencyFilterChip({
    required this.agencyName,
    required this.onClear,
    this.onShowQr,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Flexible(
            child: InputChip(
              avatar: Icon(
                Icons.business_rounded,
                size: 16,
                color: colorScheme.onSecondaryContainer,
              ),
              label: Text(agencyName),
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: colorScheme.secondaryContainer,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              deleteIcon: Icon(
                Icons.close_rounded,
                size: 18,
                color: colorScheme.onSecondaryContainer,
              ),
              onDeleted: () {
                HapticFeedback.lightImpact();
                onClear();
              },
            ),
          ),
          if (onShowQr != null)
            IconButton(
              icon: const Icon(Icons.qr_code_2_rounded),
              color: colorScheme.onSurfaceVariant,
              tooltip: 'QR',
              onPressed: () {
                HapticFeedback.lightImpact();
                onShowQr!(agencyName);
              },
            ),
        ],
      ),
    );
  }
}

/// Route count indicator
class _RouteCountIndicator extends StatelessWidget {
  final int count;
  final bool isFiltered;

  const _RouteCountIndicator({required this.count, required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFiltered
                  ? colorScheme.tertiaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFiltered ? Icons.filter_list_rounded : Icons.route_rounded,
                  size: 16,
                  color: isFiltered
                      ? colorScheme.onTertiaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  TransportListLocalizations.of(context).routeCount(count),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isFiltered
                        ? colorScheme.onTertiaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading list
class _ShimmerList extends StatefulWidget {
  @override
  State<_ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<_ShimmerList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ShimmerCard(animation: _controller),
        );
      },
    );
  }
}

/// Single shimmer card
class _ShimmerCard extends StatelessWidget {
  final Animation<double> animation;

  const _ShimmerCard({required this.animation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Route badge shimmer
              Container(
                width: 56,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment(-1.0 + 2.0 * animation.value, 0),
                    end: Alignment(1.0 + 2.0 * animation.value, 0),
                    colors: [
                      colorScheme.surfaceContainerHighest,
                      colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      colorScheme.surfaceContainerHighest,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title shimmer
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + 2.0 * animation.value, 0),
                          end: Alignment(1.0 + 2.0 * animation.value, 0),
                          colors: [
                            colorScheme.surfaceContainerHighest,
                            colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                            colorScheme.surfaceContainerHighest,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle shimmer
                    Container(
                      height: 12,
                      width: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + 2.0 * animation.value, 0),
                          end: Alignment(1.0 + 2.0 * animation.value, 0),
                          colors: [
                            colorScheme.surfaceContainerHighest,
                            colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                            colorScheme.surfaceContainerHighest,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Empty state widget
class _LoadErrorState extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _LoadErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

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
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final bool isSearch;

  const _EmptyState({required this.message, required this.isSearch});

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
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearch
                    ? Icons.search_off_rounded
                    : Icons.directions_bus_outlined,
                size: 40,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearch
                  ? TransportListLocalizations.of(context).tryDifferentSearch
                  : TransportListLocalizations.of(context).pullDownToRefresh,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Menu button for opening the drawer
class _MenuButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _MenuButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            Icons.menu_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}

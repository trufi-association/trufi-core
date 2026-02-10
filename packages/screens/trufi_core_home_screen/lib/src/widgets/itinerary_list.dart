import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../cubit/route_planner_cubit.dart';
import '../models/route_planner_state.dart';
import '../../l10n/home_screen_localizations.dart';
import 'itinerary_card.dart';
import 'itinerary_detail_screen.dart';

/// List of itinerary options with inline detail view.
/// When an itinerary is tapped, shows details inline replacing the list.
class ItineraryList extends StatefulWidget {
  final void Function(routing.Itinerary itinerary)? onItineraryDetails;
  final void Function(
    BuildContext context,
    routing.Itinerary itinerary,
    LocationService locationService,
  )? onStartNavigation;
  final LocationService? locationService;

  /// Callback when a transit route badge is tapped.
  /// Provides the route code to allow navigation to route details.
  final void Function(String routeCode)? onRouteTap;

  /// When true, the list will shrink to fit content and disable its own scrolling.
  /// Use this when the list is inside a parent scrollable (e.g., bottom sheet).
  /// When false (default), the list will scroll independently.
  final bool shrinkWrap;

  /// When true, automatically shows details for the selected itinerary on first load.
  /// Used when opening from a deep link URL with a specific route.
  final bool showDetailOnLoad;

  /// Callback when detail view state changes (shown/hidden).
  final void Function(bool isShowingDetail)? onDetailStateChanged;

  const ItineraryList({
    super.key,
    this.onItineraryDetails,
    this.onStartNavigation,
    this.locationService,
    this.onRouteTap,
    this.shrinkWrap = false,
    this.showDetailOnLoad = false,
    this.onDetailStateChanged,
  });

  @override
  State<ItineraryList> createState() => _ItineraryListState();
}

class _ItineraryListState extends State<ItineraryList> {
  routing.Itinerary? _detailItinerary;
  bool _hasAutoShownDetail = false;
  // Track which groups are expanded
  final Set<String> _expandedGroups = {};

  void _toggleGroupExpanded(String signature) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expandedGroups.contains(signature)) {
        _expandedGroups.remove(signature);
      } else {
        _expandedGroups.add(signature);
      }
    });
  }

  void _showDetails(routing.Itinerary itinerary) {
    HapticFeedback.selectionClick();
    setState(() {
      _detailItinerary = itinerary;
    });
    widget.onDetailStateChanged?.call(true);
  }

  void _hideDetails() {
    HapticFeedback.lightImpact();
    setState(() {
      _detailItinerary = null;
    });
    widget.onDetailStateChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoutePlannerCubit, RoutePlannerState>(
      listener: (context, state) {
        // Clear stale local state when a new search starts or plan changes
        if (state.isLoading || state.plan == null) {
          if (_detailItinerary != null || _expandedGroups.isNotEmpty) {
            setState(() {
              _detailItinerary = null;
              _expandedGroups.clear();
            });
            widget.onDetailStateChanged?.call(false);
          }
        }
      },
      builder: (context, state) {
        final l10n = HomeScreenLocalizations.of(context);
        final cubit = context.read<RoutePlannerCubit>();
        final theme = Theme.of(context);

        if (state.isLoading) {
          return _buildShimmerLoading(theme);
        }

        if (state.hasError) {
          return _buildErrorState(context, state, l10n, theme);
        }

        final itineraries = state.plan?.itineraries;
        if (itineraries == null || itineraries.isEmpty) {
          if (!state.isPlacesDefined) {
            return _buildEmptyState(
              context,
              icon: Icons.route_rounded,
              message: l10n.selectLocations,
              theme: theme,
            );
          }
          return _buildEmptyState(
            context,
            icon: Icons.search_off_rounded,
            message: l10n.noRoutesFound,
            theme: theme,
          );
        }

        // Auto-show detail on first load if requested (e.g., from URL)
        if (widget.showDetailOnLoad &&
            !_hasAutoShownDetail &&
            state.selectedItinerary != null) {
          _hasAutoShownDetail = true;
          // Use post-frame callback to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _detailItinerary = state.selectedItinerary;
              });
              widget.onDetailStateChanged?.call(true);
            }
          });
        }

        // Show detail view only if the itinerary is still in the current plan
        if (_detailItinerary != null) {
          if (itineraries.contains(_detailItinerary)) {
            return _buildDetailView(context, _detailItinerary!);
          }
          // Stale detail from a previous search — clear it
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _detailItinerary != null) {
              setState(() {
                _detailItinerary = null;
                _expandedGroups.clear();
              });
              widget.onDetailStateChanged?.call(false);
            }
          });
        }

        // Use grouped itineraries if available, otherwise fall back to regular list
        final groupedItineraries = state.plan?.groupedItineraries;
        if (groupedItineraries != null && groupedItineraries.isNotEmpty) {
          return _buildGroupedListView(context, groupedItineraries, state, cubit);
        }

        // Fallback to non-grouped list view
        return _buildListView(context, itineraries, state, cubit);
      },
    );
  }

  Widget _buildDetailView(BuildContext context, routing.Itinerary itinerary) {
    return ItineraryDetailContent(
      itinerary: itinerary,
      shrinkWrap: widget.shrinkWrap,
      onBack: _hideDetails,
      onRouteTap: widget.onRouteTap,
      onStartNavigation:
          widget.onStartNavigation != null && widget.locationService != null
              ? () => widget.onStartNavigation!(
                    context,
                    itinerary,
                    widget.locationService!,
                  )
              : null,
    );
  }

  Widget _buildGroupedListView(
    BuildContext context,
    List<routing.ItineraryGroup> groups,
    RoutePlannerState state,
    RoutePlannerCubit cubit,
  ) {
    final l10n = HomeScreenLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      shrinkWrap: widget.shrinkWrap,
      physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final isExpanded = _expandedGroups.contains(group.signature);
        final isSelected = group.alternatives.contains(state.selectedItinerary);

        return TweenAnimationBuilder<double>(
          key: ValueKey('group-$index'),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Column(
            children: [
              // Main card for representative itinerary
              ItineraryCard(
                itinerary: group.representative,
                isSelected: isSelected && state.selectedItinerary == group.representative,
                alternativeCount: group.hasAlternatives ? group.additionalCount : null,
                isExpanded: isExpanded,
                onTap: () {
                  cubit.selectItinerary(group.representative);
                  if (widget.onItineraryDetails != null) {
                    widget.onItineraryDetails!(group.representative);
                  } else {
                    _showDetails(group.representative);
                  }
                },
                onExpandTap: group.hasAlternatives
                    ? () => _toggleGroupExpanded(group.signature)
                    : null,
                onDetailsTap: null,
                onStartNavigation:
                    widget.onStartNavigation != null && widget.locationService != null
                        ? () => widget.onStartNavigation!(
                              context,
                              group.representative,
                              widget.locationService!,
                            )
                        : null,
              ),
              // Expanded alternatives
              if (isExpanded && group.hasAlternatives)
                _buildAlternatives(context, group, state, cubit, l10n, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlternatives(
    BuildContext context,
    routing.ItineraryGroup group,
    RoutePlannerState state,
    RoutePlannerCubit cubit,
    HomeScreenLocalizations l10n,
    ThemeData theme,
  ) {
    // Skip the first one (representative)
    final alternatives = group.alternatives.skip(1).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              l10n.otherDepartures,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...alternatives.map((itinerary) {
            final isSelected = itinerary == state.selectedItinerary;
            return _AlternativeTimeCard(
              itinerary: itinerary,
              isSelected: isSelected,
              onTap: () {
                cubit.selectItinerary(itinerary);
                if (widget.onItineraryDetails != null) {
                  widget.onItineraryDetails!(itinerary);
                } else {
                  _showDetails(itinerary);
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    List<routing.Itinerary> itineraries,
    RoutePlannerState state,
    RoutePlannerCubit cubit,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      shrinkWrap: widget.shrinkWrap,
      physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: itineraries.length,
      itemBuilder: (context, index) {
        final itinerary = itineraries[index];
        final isSelected = itinerary == state.selectedItinerary;

        return TweenAnimationBuilder<double>(
          key: ValueKey('itinerary-$index'),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: ItineraryCard(
            itinerary: itinerary,
            isSelected: isSelected,
            onTap: () {
              cubit.selectItinerary(itinerary);
              // Show details inline or use custom callback
              if (widget.onItineraryDetails != null) {
                widget.onItineraryDetails!(itinerary);
              } else {
                _showDetails(itinerary);
              }
            },
            onDetailsTap: null,
            onStartNavigation:
                widget.onStartNavigation != null && widget.locationService != null
                    ? () => widget.onStartNavigation!(
                          context,
                          itinerary,
                          widget.locationService!,
                        )
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: widget.shrinkWrap,
      physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: 3,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(opacity: value * 0.7, child: child);
          },
          child: _ShimmerCard(theme: theme, delay: index * 200),
        );
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    RoutePlannerState state,
    HomeScreenLocalizations l10n,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 32,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.error ?? l10n.errorNoRoutes,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () {
              context.read<RoutePlannerCubit>().fetchPlan();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, size: 18),
                const SizedBox(width: 8),
                Text(l10n.buttonTryAgain),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading card placeholder
class _ShimmerCard extends StatefulWidget {
  final ThemeData theme;
  final int delay;

  const _ShimmerCard({required this.theme, this.delay = 0});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.theme.colorScheme.surfaceContainerHighest;
    final highlightColor = widget.theme.colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.theme.dividerColor.withValues(alpha: 0.3),
              ),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [baseColor, highlightColor, baseColor],
                stops: [
                  (_animation.value - 0.3).clamp(0.0, 1.0),
                  _animation.value.clamp(0.0, 1.0),
                  (_animation.value + 0.3).clamp(0.0, 1.0),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    _shimmerBox(width: 70, height: 28, radius: 20),
                    const SizedBox(width: 12),
                    _shimmerBox(width: 50, height: 20),
                    const SizedBox(width: 8),
                    _shimmerBox(width: 16, height: 16),
                    const SizedBox(width: 8),
                    _shimmerBox(width: 50, height: 20),
                  ],
                ),
                const SizedBox(height: 10),
                // Transport summary row
                _shimmerBox(width: double.infinity, height: 40, radius: 12),
                const SizedBox(height: 8),
                // Footer row
                Row(
                  children: [
                    _shimmerBox(width: 60, height: 16),
                    const SizedBox(width: 8),
                    _shimmerBox(width: 60, height: 16),
                    const Spacer(),
                    _shimmerBox(width: 70, height: 28, radius: 14),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surfaceContainerHigh.withValues(
          alpha: 0.5,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Compact card for alternative departure times
class _AlternativeTimeCard extends StatelessWidget {
  final routing.Itinerary itinerary;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlternativeTimeCard({
    required this.itinerary,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = HomeScreenLocalizations.of(context);
    final timeFormat = intl.DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withValues(alpha: 0.3),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.departsAt(timeFormat.format(itinerary.startTime)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  timeFormat.format(itinerary.endTime),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

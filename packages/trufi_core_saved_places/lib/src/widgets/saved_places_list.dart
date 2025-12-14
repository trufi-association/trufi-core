import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/saved_places_cubit.dart';
import '../models/saved_place.dart';
import '../../l10n/saved_places_localizations.dart';
import 'saved_place_tile.dart';

/// A list widget that displays saved places organized by sections.
class SavedPlacesList extends StatefulWidget {
  final void Function(SavedPlace place)? onPlaceTap;
  final void Function(SavedPlace place)? onPlaceEdit;
  final void Function(SavedPlace place)? onPlaceDelete;
  final bool showHistory;
  final int maxHistoryItems;

  const SavedPlacesList({
    super.key,
    this.onPlaceTap,
    this.onPlaceEdit,
    this.onPlaceDelete,
    this.showHistory = true,
    this.maxHistoryItems = 10,
  });

  @override
  State<SavedPlacesList> createState() => _SavedPlacesListState();
}

class _SavedPlacesListState extends State<SavedPlacesList>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    if (!_hasAnimated) {
      _hasAnimated = true;
      _staggerController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedPlacesCubit, SavedPlacesState>(
      builder: (context, state) {
        if (state.status == SavedPlacesStatus.loading) {
          return _ShimmerLoadingList();
        }

        if (state.status == SavedPlacesStatus.error) {
          return _ErrorState(
            message: state.errorMessage ?? 'Error loading places',
            onRetry: () => context.read<SavedPlacesCubit>().initialize(),
          );
        }

        // Check if there are any places at all
        final hasAnyPlaces = state.home != null ||
            state.work != null ||
            state.otherPlaces.isNotEmpty ||
            (widget.showHistory && state.history.isNotEmpty);

        if (!hasAnyPlaces) {
          return _EmptyState();
        }

        // Trigger stagger animation when content is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _triggerAnimation();
        });

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildDefaultPlacesSection(context, state),
            if (state.otherPlaces.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildOtherPlacesSection(context, state),
            ],
            if (widget.showHistory && state.history.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildHistorySection(context, state),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAnimatedItem({
    required int index,
    required Widget child,
    int totalItems = 10,
  }) {
    final startTime = (index / totalItems).clamp(0.0, 0.6);
    final endTime = ((index / totalItems) + 0.4).clamp(0.0, 1.0);

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(startTime, endTime, curve: Curves.easeOutCubic),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildDefaultPlacesSection(
    BuildContext context,
    SavedPlacesState state,
  ) {
    final localization = SavedPlacesLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedItem(
          index: 0,
          child: _buildSectionHeader(
            context,
            localization?.defaultPlaces ?? 'Default Places',
            Icons.bookmark_rounded,
          ),
        ),
        const SizedBox(height: 12),
        _buildAnimatedItem(
          index: 1,
          child: _buildDefaultPlaceTile(
            context,
            state.home,
            SavedPlaceType.home,
            localization?.home ?? 'Home',
            localization?.setHome ?? 'Set home address',
            Icons.home_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(height: 10),
        _buildAnimatedItem(
          index: 2,
          child: _buildDefaultPlaceTile(
            context,
            state.work,
            SavedPlaceType.work,
            localization?.work ?? 'Work',
            localization?.setWork ?? 'Set work address',
            Icons.work_rounded,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultPlaceTile(
    BuildContext context,
    SavedPlace? place,
    SavedPlaceType type,
    String title,
    String setLabel,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (place != null) {
      return SavedPlaceTile(
        place: place,
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onPlaceTap?.call(place);
        },
        onEdit: widget.onPlaceEdit != null
            ? () {
                HapticFeedback.lightImpact();
                widget.onPlaceEdit?.call(place);
              }
            : null,
        onDelete: widget.onPlaceDelete != null
            ? () {
                HapticFeedback.lightImpact();
                widget.onPlaceDelete?.call(place);
              }
            : null,
      );
    }

    // Empty placeholder for unset default places
    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onPlaceEdit?.call(SavedPlace(
            id: '${type.name}_placeholder',
            name: title,
            latitude: 0,
            longitude: 0,
            type: type,
            createdAt: DateTime.now(),
          ));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      setLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherPlacesSection(
    BuildContext context,
    SavedPlacesState state,
  ) {
    final localization = SavedPlacesLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedItem(
          index: 3,
          child: _buildSectionHeader(
            context,
            localization?.customPlaces ?? 'Other Places',
            Icons.place_rounded,
          ),
        ),
        const SizedBox(height: 12),
        ...state.otherPlaces.asMap().entries.map(
              (entry) => _buildAnimatedItem(
                index: 4 + entry.key,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SavedPlaceTile(
                    place: entry.value,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onPlaceTap?.call(entry.value);
                    },
                    onEdit: widget.onPlaceEdit != null
                        ? () {
                            HapticFeedback.lightImpact();
                            widget.onPlaceEdit?.call(entry.value);
                          }
                        : null,
                    onDelete: widget.onPlaceDelete != null
                        ? () {
                            HapticFeedback.lightImpact();
                            widget.onPlaceDelete?.call(entry.value);
                          }
                        : null,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    SavedPlacesState state,
  ) {
    final localization = SavedPlacesLocalizations.of(context);
    final cubit = context.read<SavedPlacesCubit>();
    final historyItems = state.recentHistory.take(widget.maxHistoryItems).toList();
    final baseIndex = 4 + state.otherPlaces.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedItem(
          index: baseIndex,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(
                context,
                localization?.recentPlaces ?? 'Recent',
                Icons.history_rounded,
              ),
              _ClearHistoryButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  cubit.clearHistory();
                },
                label: localization?.clearHistory ?? 'Clear',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...historyItems.asMap().entries.map(
              (entry) => _buildAnimatedItem(
                index: baseIndex + 1 + entry.key,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SavedPlaceTile(
                    place: entry.value,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onPlaceTap?.call(entry.value);
                    },
                    onDelete: () {
                      HapticFeedback.lightImpact();
                      cubit.removeFromHistory(entry.value.id);
                    },
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clear history button with subtle styling
class _ClearHistoryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _ClearHistoryButton({
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_sweep_rounded,
                size: 16,
                color: colorScheme.error.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.error.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading skeleton for the saved places list
class _ShimmerLoadingList extends StatefulWidget {
  @override
  State<_ShimmerLoadingList> createState() => _ShimmerLoadingListState();
}

class _ShimmerLoadingListState extends State<_ShimmerLoadingList>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colorScheme.surfaceContainerHighest,
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                colorScheme.surfaceContainerHighest,
              ],
              stops: [
                (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                _shimmerController.value,
                (_shimmerController.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Section header skeleton
          _ShimmerSectionHeader(),
          const SizedBox(height: 12),
          // Default places skeletons
          _ShimmerPlaceTile(),
          const SizedBox(height: 10),
          _ShimmerPlaceTile(),
          const SizedBox(height: 24),
          // Other places section
          _ShimmerSectionHeader(),
          const SizedBox(height: 12),
          _ShimmerPlaceTile(),
          const SizedBox(height: 10),
          _ShimmerPlaceTile(),
          const SizedBox(height: 10),
          _ShimmerPlaceTile(),
        ],
      ),
    );
  }
}

class _ShimmerSectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerPlaceTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 180,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          // Menu button placeholder
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no places are saved
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localization = SavedPlacesLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_add_rounded,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localization?.noPlacesSaved ?? 'No places saved yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your home, work, and favorite places\nfor quick access',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state with retry option
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorState({
    required this.message,
    this.onRetry,
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
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

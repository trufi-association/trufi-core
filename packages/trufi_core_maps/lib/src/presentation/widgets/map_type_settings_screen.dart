import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'map_type_option.dart';

/// Full-screen settings screen for selecting map type and optional POI layers.
class MapTypeSettingsScreen extends StatefulWidget {
  /// Currently selected map index.
  final int currentMapIndex;

  /// List of available map type options.
  final List<MapTypeOption> mapOptions;

  /// Callback when map type is changed.
  final ValueChanged<int> onMapTypeChanged;

  /// Title displayed in the app bar.
  final String? appBarTitle;

  /// Section title displayed above the map type list.
  final String? sectionTitle;

  /// Text for the apply button.
  final String? applyButtonText;

  /// Optional: Widget to display additional settings (e.g., POI layers).
  /// This will be displayed below the map type selection.
  final Widget? additionalSettings;

  const MapTypeSettingsScreen({
    super.key,
    required this.currentMapIndex,
    required this.mapOptions,
    required this.onMapTypeChanged,
    this.appBarTitle,
    this.sectionTitle,
    this.applyButtonText,
    this.additionalSettings,
  });

  @override
  State<MapTypeSettingsScreen> createState() => _MapTypeSettingsScreenState();
}

class _MapTypeSettingsScreenState extends State<MapTypeSettingsScreen>
    with SingleTickerProviderStateMixin {
  late int selectedMapIndex;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    selectedMapIndex = widget.currentMapIndex;
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem({
    required int index,
    required Widget child,
  }) {
    final totalItems = widget.mapOptions.length + 2; // +2 for header and button
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modern header
            _buildAnimatedItem(
              index: 0,
              child: _MapSettingsHeader(
                title: widget.appBarTitle ?? 'Map Settings',
                onClose: () => Navigator.of(context).pop(),
              ),
            ),

            // Map options list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                children: [
                  // Map type section header
                  _buildAnimatedItem(
                    index: 1,
                    child: _MapTypeHeroSection(
                      title: widget.sectionTitle ?? 'Map Type',
                    ),
                  ),
                  // Map type options
                  ...List.generate(widget.mapOptions.length, (index) {
                    final option = widget.mapOptions[index];
                    final isSelected = selectedMapIndex == index;

                    return _buildAnimatedItem(
                      index: index + 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _ModernMapTypeCard(
                          option: option,
                          isSelected: isSelected,
                          onTap: () => _onMapTypeSelected(index),
                        ),
                      ),
                    );
                  }),

                  // Additional settings section (e.g., POI layers)
                  if (widget.additionalSettings != null) ...[
                    const SizedBox(height: 16),
                    widget.additionalSettings!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapTypeSelected(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      selectedMapIndex = index;
    });
    widget.onMapTypeChanged(index);
  }
}

/// Modern header for map settings screen
class _MapSettingsHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _MapSettingsHeader({
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Close button
          Material(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onClose();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple text header for map type section
class _MapTypeHeroSection extends StatelessWidget {
  final String title;

  const _MapTypeHeroSection({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
            'Choose your preferred map style',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern map type card with improved styling
class _ModernMapTypeCard extends StatelessWidget {
  final MapTypeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernMapTypeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Preview image
              _buildPreviewImage(colorScheme),
              const SizedBox(width: 14),
              // Map info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Selection indicator with animation
              _SelectionIndicator(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewImage(ColorScheme colorScheme) {
    if (option.previewImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 72,
          height: 72,
          child: option.previewImage,
        ),
      );
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.map_rounded,
        size: 32,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Animated selection indicator
class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;

  const _SelectionIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? colorScheme.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outline,
          width: 2,
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isSelected ? 1.0 : 0.0,
        child: Icon(
          Icons.check_rounded,
          size: 18,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}

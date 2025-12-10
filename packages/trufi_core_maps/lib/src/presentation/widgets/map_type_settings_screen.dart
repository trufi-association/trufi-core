import 'package:flutter/material.dart';

import 'map_type_option.dart';

/// Full-screen settings screen for selecting map type.
class MapTypeSettingsScreen extends StatefulWidget {
  /// Currently selected map index.
  final int currentMapIndex;

  /// List of available map type options.
  final List<MapTypeOption> mapOptions;

  /// Callback when map type is changed.
  final ValueChanged<int> onMapTypeChanged;

  /// Title displayed in the app bar.
  final String? appBarTitle;

  /// Section title displayed above the list.
  final String? sectionTitle;

  /// Text for the apply button.
  final String? applyButtonText;

  const MapTypeSettingsScreen({
    super.key,
    required this.currentMapIndex,
    required this.mapOptions,
    required this.onMapTypeChanged,
    this.appBarTitle,
    this.sectionTitle,
    this.applyButtonText,
  });

  @override
  State<MapTypeSettingsScreen> createState() => _MapTypeSettingsScreenState();
}

class _MapTypeSettingsScreenState extends State<MapTypeSettingsScreen> {
  late int selectedMapIndex;

  @override
  void initState() {
    super.initState();
    selectedMapIndex = widget.currentMapIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle ?? 'Map Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.sectionTitle ?? 'Map Type',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.mapOptions.length,
                itemBuilder: (context, index) {
                  final option = widget.mapOptions[index];
                  final isSelected = selectedMapIndex == index;

                  return _MapTypeCard(
                    option: option,
                    isSelected: isSelected,
                    onTap: () => _onMapTypeSelected(index, option),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(widget.applyButtonText ?? 'Apply Changes'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapTypeSelected(int index, MapTypeOption option) {
    setState(() {
      selectedMapIndex = index;
    });
    widget.onMapTypeChanged(index);
  }
}

class _MapTypeCard extends StatelessWidget {
  final MapTypeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapTypeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildPreviewImage(theme),
              const SizedBox(width: 16),
              _buildMapInfo(theme),
              _buildSelectionIndicator(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewImage(ThemeData theme) {
    if (option.previewImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 80,
          height: 80,
          child: option.previewImage,
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.map,
        size: 40,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMapInfo(ThemeData theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            option.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionIndicator(ThemeData theme) {
    if (isSelected) {
      return Icon(
        Icons.check_circle,
        color: theme.colorScheme.primary,
        size: 32,
      );
    }

    return Icon(
      Icons.circle_outlined,
      color: theme.colorScheme.outlineVariant,
      size: 32,
    );
  }
}

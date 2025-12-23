import 'package:flutter/material.dart';

import '../models/saved_place.dart';
import '../../l10n/saved_places_localizations.dart';

/// Callback to open a map picker and return coordinates.
typedef OnChooseOnMap =
    Future<({double latitude, double longitude})?> Function({
      double? initialLatitude,
      double? initialLongitude,
    });

/// Bottom sheet for creating or editing a saved place.
///
/// Design inspired by Google Maps and Apple Maps:
/// - Modal bottom sheet instead of dialog
/// - Large tappable location card with map preview
/// - Segmented button for type selection
/// - Clean Material 3 styling
class EditPlaceDialog extends StatefulWidget {
  final SavedPlace? place;
  final void Function(SavedPlace place) onSave;
  final String? title;
  final OnChooseOnMap? onChooseOnMap;
  final double defaultLatitude;
  final double defaultLongitude;

  const EditPlaceDialog({
    super.key,
    this.place,
    required this.onSave,
    this.title,
    this.onChooseOnMap,
    this.defaultLatitude = 0.0,
    this.defaultLongitude = 0.0,
  });

  /// Shows the edit/create place bottom sheet.
  static Future<SavedPlace?> show(
    BuildContext context, {
    SavedPlace? place,
    String? title,
    OnChooseOnMap? onChooseOnMap,
    double defaultLatitude = 0.0,
    double defaultLongitude = 0.0,
  }) {
    return showModalBottomSheet<SavedPlace>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditPlaceDialog(
        place: place,
        title: title,
        onChooseOnMap: onChooseOnMap,
        defaultLatitude: defaultLatitude,
        defaultLongitude: defaultLongitude,
        onSave: (updatedPlace) => Navigator.of(context).pop(updatedPlace),
      ),
    );
  }

  @override
  State<EditPlaceDialog> createState() => _EditPlaceDialogState();
}

class _EditPlaceDialogState extends State<EditPlaceDialog> {
  late TextEditingController _nameController;
  late SavedPlaceType _selectedType;
  late double _latitude;
  late double _longitude;
  String? _selectedIcon;
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();

  bool get _isEditing => widget.place != null;
  bool get _hasLocation => _latitude != 0.0 || _longitude != 0.0;

  static const List<_IconOption> _iconOptions = [
    _IconOption('place', Icons.place_outlined),
    _IconOption('star', Icons.star_outline),
    _IconOption('favorite', Icons.favorite_outline),
    _IconOption('bookmark', Icons.bookmark_outline),
    _IconOption('school', Icons.school_outlined),
    _IconOption('shopping', Icons.shopping_bag_outlined),
    _IconOption('restaurant', Icons.restaurant_outlined),
    _IconOption('cafe', Icons.coffee_outlined),
    _IconOption('gym', Icons.fitness_center_outlined),
    _IconOption('hospital', Icons.local_hospital_outlined),
    _IconOption('park', Icons.park_outlined),
    _IconOption('airport', Icons.flight_outlined),
    _IconOption('train', Icons.train_outlined),
    _IconOption('bus', Icons.directions_bus_outlined),
    _IconOption('parking', Icons.local_parking_outlined),
    _IconOption('gas', Icons.local_gas_station_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.place?.name ?? '');
    _selectedType = widget.place?.type ?? SavedPlaceType.other;
    _latitude = widget.place?.latitude ?? widget.defaultLatitude;
    _longitude = widget.place?.longitude ?? widget.defaultLongitude;
    _selectedIcon = widget.place?.iconName ?? 'place';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  String _getTypeLabel(SavedPlaceType type) {
    final localization = SavedPlacesLocalizations.of(context);
    switch (type) {
      case SavedPlaceType.home:
        return localization.home;
      case SavedPlaceType.work:
        return localization.work;
      case SavedPlaceType.other:
        return localization.customPlaces;
      case SavedPlaceType.history:
        return 'History';
    }
  }

  IconData _getTypeIcon(SavedPlaceType type) {
    switch (type) {
      case SavedPlaceType.home:
        return Icons.home_outlined;
      case SavedPlaceType.work:
        return Icons.work_outline;
      case SavedPlaceType.other:
        return Icons.place_outlined;
      case SavedPlaceType.history:
        return Icons.history;
    }
  }

  IconData _getSelectedIcon() {
    if (_selectedType == SavedPlaceType.home) return Icons.home;
    if (_selectedType == SavedPlaceType.work) return Icons.work;
    final option = _iconOptions.firstWhere(
      (o) => o.name == _selectedIcon,
      orElse: () => _iconOptions.first,
    );
    return option.icon;
  }

  Color _getTypeColor() {
    final theme = Theme.of(context);
    switch (_selectedType) {
      case SavedPlaceType.home:
        return Colors.blue;
      case SavedPlaceType.work:
        return Colors.orange;
      case SavedPlaceType.other:
        return theme.colorScheme.primary;
      case SavedPlaceType.history:
        return Colors.grey;
    }
  }

  Future<void> _openMapPicker() async {
    if (widget.onChooseOnMap == null) return;

    // Dismiss keyboard first
    _nameFocusNode.unfocus();

    final result = await widget.onChooseOnMap!(
      initialLatitude: _hasLocation ? _latitude : null,
      initialLongitude: _hasLocation ? _longitude : null,
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = SavedPlacesLocalizations.of(context);
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              _buildDragHandle(theme),

              // Header
              _buildHeader(theme, localization),

              const Divider(height: 1),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview icon and name
                      _buildPreviewCard(theme),

                      const SizedBox(height: 24),

                      // Name input
                      _buildNameField(theme, localization),

                      const SizedBox(height: 24),

                      // Type selection
                      _buildTypeSelection(theme, localization),

                      const SizedBox(height: 24),

                      // Location card
                      _buildLocationCard(theme, localization),

                      // Icon selection (only for "other" type)
                      if (_selectedType == SavedPlaceType.other) ...[
                        const SizedBox(height: 24),
                        _buildIconSelection(theme, localization),
                      ],

                      const SizedBox(height: 32),

                      // Save button
                      _buildSaveButton(theme, localization),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(ThemeData theme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, SavedPlacesLocalizations? localization) {
    final title =
        widget.title ??
        (_isEditing
            ? (localization?.editPlace ?? 'Edit Place')
            : (localization?.addPlace ?? 'Add Place'));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 8, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: localization?.cancel ?? 'Cancel',
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme) {
    final color = _getTypeColor();
    final name = _nameController.text.trim();
    final displayName = name.isEmpty
        ? (SavedPlacesLocalizations.of(context).name)
        : name;

    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_getSelectedIcon(), size: 36, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: theme.textTheme.titleMedium?.copyWith(
              color: name.isEmpty
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(
    ThemeData theme,
    SavedPlacesLocalizations? localization,
  ) {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: localization?.name ?? 'Name',
        hintText: localization?.enterName ?? 'Enter a name for this place',
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        prefixIcon: const Icon(Icons.label_outline),
      ),
      onChanged: (_) => setState(() {}),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return localization?.nameRequired ?? 'Name is required';
        }
        return null;
      },
    );
  }

  Widget _buildTypeSelection(
    ThemeData theme,
    SavedPlacesLocalizations? localization,
  ) {
    final types = SavedPlaceType.values
        .where((t) => t != SavedPlaceType.history)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization?.type ?? 'Type',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<SavedPlaceType>(
          segments: types.map((type) {
            return ButtonSegment<SavedPlaceType>(
              value: type,
              label: Text(_getTypeLabel(type)),
              icon: Icon(_getTypeIcon(type)),
            );
          }).toList(),
          selected: {_selectedType},
          onSelectionChanged: (selected) {
            setState(() => _selectedType = selected.first);
          },
          style: ButtonStyle(visualDensity: VisualDensity.comfortable),
        ),
      ],
    );
  }

  Widget _buildLocationCard(
    ThemeData theme,
    SavedPlacesLocalizations? localization,
  ) {
    final hasError = !_hasLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization?.location ?? 'Location',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: hasError
              ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onChooseOnMap != null ? _openMapPicker : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Location icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _hasLocation
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _hasLocation ? Icons.location_on : Icons.location_off,
                      color: _hasLocation
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Location text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasLocation
                              ? (localization?.locationSelected ??
                                    'Location selected')
                              : (localization?.noLocationSelected ??
                                    'No location selected'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: hasError ? theme.colorScheme.error : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _hasLocation
                              ? '${_latitude.toStringAsFixed(5)}, ${_longitude.toStringAsFixed(5)}'
                              : (localization?.tapToSelectLocation ??
                                    'Tap to select on map'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow icon
                  if (widget.onChooseOnMap != null)
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              localization?.locationRequired ?? 'Please select a location',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIconSelection(
    ThemeData theme,
    SavedPlacesLocalizations? localization,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization?.selectIcon ?? 'Icon',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _iconOptions.length,
          itemBuilder: (context, index) {
            final option = _iconOptions[index];
            final isSelected = _selectedIcon == option.name;

            return Material(
              color: isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => setState(() => _selectedIcon = option.name),
                child: Container(
                  decoration: isSelected
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        )
                      : null,
                  child: Icon(
                    option.icon,
                    size: 22,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    ThemeData theme,
    SavedPlacesLocalizations? localization,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.check),
        label: Text(
          localization?.save ?? 'Save Place',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasLocation) {
      setState(() {}); // Trigger rebuild to show error state
      return;
    }

    final SavedPlace updatedPlace;

    if (_isEditing) {
      updatedPlace = widget.place!.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        latitude: _latitude,
        longitude: _longitude,
        iconName: _selectedType == SavedPlaceType.other ? _selectedIcon : null,
      );
    } else {
      updatedPlace = SavedPlace(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        type: _selectedType,
        iconName: _selectedType == SavedPlaceType.other ? _selectedIcon : null,
        createdAt: DateTime.now(),
      );
    }

    widget.onSave(updatedPlace);
  }
}

class _IconOption {
  final String name;
  final IconData icon;

  const _IconOption(this.name, this.icon);
}

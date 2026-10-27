import 'package:flutter/material.dart';

import '../models/saved_place.dart';
import '../models/saved_place_icons.dart';
import '../../l10n/saved_places_localizations.dart';

/// Callback to open a map picker and return coordinates.
typedef OnChooseOnMap =
    Future<({double latitude, double longitude})?> Function({
      double? initialLatitude,
      double? initialLongitude,
    });

/// Whether [name] is already used by another saved place — see
/// `SavedPlacesCubit.hasSameName`. The sheet only shows a notice; it never
/// blocks the save.
typedef IsPlaceNameTaken = bool Function(String name);

/// Turns a picked point into a human-readable address (reverse geocode).
/// Null, an empty string or a throw all mean "unknown": the place is then
/// saved with its coordinates as address.
typedef OnResolveAddress =
    Future<String?> Function(double latitude, double longitude);

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

  /// Answers, while the user types, whether the name is already in use by
  /// another saved place; a soft notice then appears under the field
  /// (#1003). Injected rather than read from a cubit because the sheet is a
  /// separate route and `SavedPlacesScreen(repository:)` provides its cubit
  /// below the navigator.
  final IsPlaceNameTaken? isNameTaken;

  /// Resolves the address of a point picked on the map (and of an existing
  /// place that has none), shown on the location card and stored with the
  /// place so the list can tell same-named rows apart (#1003). Without it
  /// the place is saved with its coordinates as address.
  final OnResolveAddress? onResolveAddress;

  const EditPlaceDialog({
    super.key,
    this.place,
    required this.onSave,
    this.title,
    this.onChooseOnMap,
    this.defaultLatitude = 0.0,
    this.defaultLongitude = 0.0,
    this.isNameTaken,
    this.onResolveAddress,
  });

  /// Shows the edit/create place bottom sheet.
  static Future<SavedPlace?> show(
    BuildContext context, {
    SavedPlace? place,
    String? title,
    OnChooseOnMap? onChooseOnMap,
    double defaultLatitude = 0.0,
    double defaultLongitude = 0.0,
    IsPlaceNameTaken? isNameTaken,
    OnResolveAddress? onResolveAddress,
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
        isNameTaken: isNameTaken,
        onResolveAddress: onResolveAddress,
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

  /// Resolved address of the current coordinates; null until a lookup
  /// answers (or when none is configured), in which case the place is saved
  /// with [formatCoordinates] instead.
  String? _address;

  /// Sequence of address lookups: a user who re-picks while a slow lookup is
  /// in flight must not get the first point's street under the second point.
  int _addressRequest = 0;

  bool get _isEditing => widget.place != null;
  bool get _hasLocation => _latitude != 0.0 || _longitude != 0.0;

  // Single source of truth shared with SavedPlaceTile — see #985.
  static const List<SavedPlaceIcon> _iconOptions = savedPlaceIcons;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.place?.name ?? '');
    _selectedType = widget.place?.type ?? SavedPlaceType.other;
    // For new places, start with no location (0.0) so the user must select one.
    // For existing places, use their saved coordinates.
    _latitude = widget.place?.latitude ?? 0.0;
    _longitude = widget.place?.longitude ?? 0.0;
    _selectedIcon = widget.place?.iconName ?? 'place';
    _address = _cleanAddress(widget.place?.address);
    // A place saved before #1003 has coordinates but no address, and one
    // saved offline (or before its lookup answered) carries them as its
    // address: resolve both now so a plain edit (icon, name) fills the
    // subtitle too.
    if (_hasLocation && _address == null) _resolveAddress();
  }

  /// Null for an empty address and for a bare "lat, lon" label: coordinates
  /// are the fallback, never a resolved address, so a place that stores them
  /// is looked up again and, failing that, keeps the same label.
  static String? _cleanAddress(String? address) {
    final trimmed = address?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return looksLikeCoordinates(trimmed) ? null : trimmed;
  }

  Future<void> _resolveAddress() async {
    final resolve = widget.onResolveAddress;
    if (resolve == null || !_hasLocation) return;
    final request = ++_addressRequest;
    final latitude = _latitude;
    final longitude = _longitude;

    String? address;
    try {
      address = await resolve(latitude, longitude);
    } catch (_) {
      address = null; // unknown: the coordinates fallback applies
    }

    if (!mounted || request != _addressRequest) return;
    setState(() => _address = _cleanAddress(address));
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
        return localization.history;
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
    return option.outlined;
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
      initialLatitude: _hasLocation ? _latitude : widget.defaultLatitude,
      initialLongitude: _hasLocation ? _longitude : widget.defaultLongitude,
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _address = null;
      });
      _resolveAddress();
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

  Widget _buildHeader(ThemeData theme, SavedPlacesLocalizations localization) {
    final title =
        widget.title ??
        (_isEditing ? (localization.editPlace) : (localization.addPlace));

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
            tooltip: localization.cancel,
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

  bool get _isNameTaken =>
      widget.isNameTaken?.call(_nameController.text) ?? false;

  Widget _buildNameField(
    ThemeData theme,
    SavedPlacesLocalizations localization,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: localization.name,
            hintText: localization.enterName,
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
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
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
              return localization.nameRequired;
            }
            return null;
          },
        ),
        // Soft notice, same slot and type as the location card's error line
        // but not an error: the name stays valid and Save keeps working
        // (#1003 — the list showed three identical "Parada" rows).
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _isNameTaken
              ? _NameInUseNotice(message: localization.placeNameInUse)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildTypeSelection(
    ThemeData theme,
    SavedPlacesLocalizations localization,
  ) {
    final types = SavedPlaceType.values
        .where((t) => t != SavedPlaceType.history)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.type,
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
    SavedPlacesLocalizations localization,
  ) {
    final hasError = !_hasLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.location,
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
                              ? (localization.locationSelected)
                              : (localization.noLocationSelected),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: hasError ? theme.colorScheme.error : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _hasLocation
                              ? _address ??
                                    formatCoordinates(_latitude, _longitude)
                              : (localization.tapToSelectLocation),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: Text(
              localization.locationRequired,
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
    SavedPlacesLocalizations localization,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.selectIcon,
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
                    option.outlined,
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
    SavedPlacesLocalizations localization,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.check),
        label: Text(
          localization.save,
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
    // Never save without a subtitle: the list is where same-named places
    // get confused (#1003).
    final address = _address ?? formatCoordinates(_latitude, _longitude);

    if (_isEditing) {
      updatedPlace = widget.place!.copyWith(
        name: _nameController.text.trim(),
        address: address,
        type: _selectedType,
        latitude: _latitude,
        longitude: _longitude,
        iconName: _selectedType == SavedPlaceType.other ? _selectedIcon : null,
      );
    } else {
      updatedPlace = SavedPlace(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        address: address,
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

/// "You already have a place with this name": an info row under the name
/// field — icon 16 in `primary` (the ecosystem's informational accent) +
/// bodySmall onSurfaceVariant — announced to screen readers when it appears.
/// Insets are directional: trufi-sanaa runs RTL.
class _NameInUseNotice extends StatelessWidget {
  const _NameInUseNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 8, start: 16),
      child: Semantics(
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

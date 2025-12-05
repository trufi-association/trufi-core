import 'package:flutter/material.dart';

import '../models/search_location.dart';
import '../models/search_location_bar_configuration.dart';

/// A single location input field that displays a location and triggers search on tap.
class SearchLocationField extends StatelessWidget {
  /// Whether this field is for the origin location.
  final bool isOrigin;

  /// Hint text shown when no location is selected.
  final String hintText;

  /// Widget shown at the start of the field (e.g., marker icon).
  final Widget? leadingWidget;

  /// Widget shown at the end of the field (e.g., swap or reset button).
  final Widget? trailingWidget;

  /// The currently selected location, if any.
  final SearchLocation? value;

  /// Called when the field is tapped to search for a location.
  final OnSearchLocation onSearch;

  /// Called when a location is selected from search.
  final OnLocationSelected onLocationSelected;

  /// Border radius of the field.
  final BorderRadius borderRadius;

  /// Height of the field.
  final double height;

  const SearchLocationField({
    super.key,
    required this.isOrigin,
    required this.hintText,
    required this.onSearch,
    required this.onLocationSelected,
    this.leadingWidget,
    this.trailingWidget,
    this.value,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.height = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final location = await onSearch(isOrigin: isOrigin);
              if (location != null) {
                onLocationSelected(location);
              }
            },
            child: Container(
              height: height,
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: borderRadius,
              ),
              child: Row(
                children: <Widget>[
                  if (leadingWidget != null)
                    SizedBox(height: 24.0, child: leadingWidget),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        value?.formattedDisplay ?? hintText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: value != null
                            ? theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              )
                            : theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (trailingWidget != null)
          SizedBox(
            width: 40.0,
            child: trailingWidget,
          ),
      ],
    );
  }
}

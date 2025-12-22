import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/poi.dart';
import '../models/poi_category.dart';

/// State for POI layers
class POILayersState {
  /// Enabled subcategories per category (category -> Set of subcategory names)
  /// If a category has no enabled subcategories, the category is considered disabled
  /// If the set is null, it means the category hasn't been initialized yet
  final Map<POICategory, Set<String>> enabledSubcategories;

  const POILayersState({
    this.enabledSubcategories = const {},
  });

  POILayersState copyWith({
    Map<POICategory, Set<String>>? enabledSubcategories,
  }) {
    return POILayersState(
      enabledSubcategories: enabledSubcategories ?? this.enabledSubcategories,
    );
  }

  /// Check if a category is enabled (has any subcategories enabled)
  bool isCategoryEnabled(POICategory category) {
    final subcats = enabledSubcategories[category];
    return subcats != null && subcats.isNotEmpty;
  }

  /// Get list of enabled categories (categories with at least one enabled subcategory)
  Set<POICategory> get enabledCategories =>
      enabledSubcategories.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => e.key)
          .toSet();

  /// Check if any category is enabled
  bool get hasEnabledCategories =>
      enabledSubcategories.values.any((subcats) => subcats.isNotEmpty);

  /// Check if a POI is enabled based on its subcategory
  bool isPOIEnabled(POI poi) {
    // Get enabled subcategories for this category
    final subcats = enabledSubcategories[poi.category];

    // If category not initialized or no subcategories enabled, POI is disabled
    if (subcats == null || subcats.isEmpty) {
      return false;
    }

    // If POI has no subcategory, check if category has any enabled subcategories
    if (poi.subcategory == null) {
      return subcats.isNotEmpty;
    }

    // Check if this specific subcategory is enabled
    return subcats.contains(poi.subcategory);
  }
}

/// Cubit for managing POI layer visibility and state.
///
/// This cubit manages POI subcategory-based visibility using subcategory-only toggling:
/// - Categories are automatically enabled when they have enabled subcategories
/// - Categories are automatically disabled when all subcategories are disabled
/// - No direct category toggle - categories are derived from subcategory state
class POILayersCubit extends Cubit<POILayersState> {
  POILayersCubit({
    Map<POICategory, Set<String>>? defaultEnabledSubcategories,
  }) : super(POILayersState(
          enabledSubcategories: defaultEnabledSubcategories ?? {},
        ));

  /// Toggle a subcategory on/off within a category
  void toggleSubcategory(POICategory category, String subcategory, bool enabled) {
    final newSubcats = Map<POICategory, Set<String>>.from(state.enabledSubcategories);

    // Get current subcategories for this category
    final currentSubcats = newSubcats[category] ?? <String>{};
    final updatedSubcats = Set<String>.from(currentSubcats);

    if (enabled) {
      updatedSubcats.add(subcategory);
    } else {
      updatedSubcats.remove(subcategory);
    }

    newSubcats[category] = updatedSubcats;
    emit(state.copyWith(enabledSubcategories: newSubcats));
  }

  /// Enable all subcategories for a category (effectively enabling the category)
  void enableCategory(POICategory category, Set<String> subcategories) {
    if (subcategories.isEmpty) return;

    final newSubcats = Map<POICategory, Set<String>>.from(state.enabledSubcategories);
    newSubcats[category] = Set<String>.from(subcategories);
    emit(state.copyWith(enabledSubcategories: newSubcats));
  }

  /// Disable all subcategories for a category (effectively disabling the category)
  void disableCategory(POICategory category) {
    final newSubcats = Map<POICategory, Set<String>>.from(state.enabledSubcategories);
    newSubcats[category] = {};
    emit(state.copyWith(enabledSubcategories: newSubcats));
  }

  /// Toggle a category on/off (enables/disables all its subcategories)
  void toggleCategory(POICategory category, bool enabled, Set<String> subcategories) {
    if (enabled) {
      enableCategory(category, subcategories);
    } else {
      disableCategory(category);
    }
  }

  /// Disable all categories
  void disableAll() {
    final newSubcats = {
      for (final cat in POICategory.values) cat: <String>{},
    };
    emit(state.copyWith(enabledSubcategories: newSubcats));
  }

  /// Enable all categories (all subcategories)
  void enableAll(Map<POICategory, Set<String>> allSubcategories) {
    final newSubcats = <POICategory, Set<String>>{};
    for (final entry in allSubcategories.entries) {
      if (entry.value.isNotEmpty) {
        newSubcats[entry.key] = entry.value;
      }
    }
    emit(state.copyWith(enabledSubcategories: newSubcats));
  }
}

/// Extension to provide easy access to POILayersCubit
extension POILayersCubitContext on BuildContext {
  POILayersCubit get poiLayersCubit => read<POILayersCubit>();
  POILayersCubit? get poiLayersCubitOrNull {
    try {
      return read<POILayersCubit>();
    } catch (_) {
      return null;
    }
  }
}

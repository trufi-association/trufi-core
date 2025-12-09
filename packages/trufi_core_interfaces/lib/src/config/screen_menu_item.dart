import 'package:flutter/material.dart';

/// Menu item configuration for the navigation drawer
/// Only contains menu-specific properties (icon, order, divider)
/// The title and route are derived from the parent TrufiScreen
class ScreenMenuItem {
  final IconData icon;
  final int order;
  final bool showDividerBefore;

  const ScreenMenuItem({
    required this.icon,
    this.order = 100,
    this.showDividerBefore = false,
  });
}

import 'package:flutter/widgets.dart';

/// Represents a single social media link
class SocialMediaLink {
  final String url;
  final IconData icon;
  final String? label;

  const SocialMediaLink({
    required this.url,
    required this.icon,
    this.label,
  });
}

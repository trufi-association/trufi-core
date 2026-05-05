import 'package:flutter/widgets.dart';

/// Represents a single social media link.
///
/// [icon] is any widget — typically a [Icon] for font glyphs or a
/// `SvgPicture.string(...)` for vector brand logos. For common platforms
/// (Facebook, Instagram, WhatsApp, Twitter/X) consider using the
/// `SocialMediaPreset` enum exported from `trufi_core_ui`.
class SocialMediaLink {
  final String url;
  final Widget icon;
  final String? label;

  const SocialMediaLink({required this.url, required this.icon, this.label});
}

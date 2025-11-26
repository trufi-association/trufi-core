// In trufi_core package - trufi_localizations_provider.dart
import 'package:flutter/widgets.dart';
import 'package:tr_translations/trufi_localizations.dart';

class TrufiLocalizationsProvider extends InheritedWidget {
  const TrufiLocalizationsProvider({
    required this.localizations,
    required super.child,
    super.key,
  });
  final TrufiLocalizations localizations;

  static TrufiLocalizations of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<TrufiLocalizationsProvider>();
    assert(provider != null, 'No TrufiLocalizationsProvider found in context');
    return provider!.localizations;
  }

  @override
  bool updateShouldNotify(TrufiLocalizationsProvider oldWidget) =>
      localizations != oldWidget.localizations;
}

import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Delegates that keep Flutter's own widget strings working for languages
/// `flutter_localizations` does not ship.
///
/// Cities localize Trufi into languages far beyond Flutter's 82 built-in
/// locales — Quechua, Aymara and Guaraní among them (see
/// `dart run trufi_core_utils:gen_extra_l10n`). Registering such a locale in
/// `supportedLocales` without these delegates leaves the tree without
/// `MaterialLocalizations`, so every `Scaffold`, `Tooltip` and `showDialog`
/// trips `debugCheckHasMaterialLocalizations` — the app cannot start in the
/// very language it was translated into.
///
/// These delegates claim support for *every* locale and serve the framework
/// strings ("Back", month names, …) of [fallbackLocale], while the app's own
/// ARB translations still come from its own delegates. The result: a Quechua
/// app is fully Quechua except for a handful of Flutter-provided labels,
/// instead of not running at all.
///
/// Register them **last**, so the real `Global*Localizations` win wherever
/// Flutter does ship translations:
///
/// ```dart
/// localizationsDelegates: [
///   ...appDelegates,
///   GlobalMaterialLocalizations.delegate,
///   GlobalWidgetsLocalizations.delegate,
///   GlobalCupertinoLocalizations.delegate,
///   ...fallbackFrameworkLocalizationsDelegates(),
/// ],
/// ```
/// Wraps [delegate] so it answers for *every* locale, serving the strings of
/// [fallbackLocale] whenever the wrapped delegate has no translation.
///
/// Trufi's generated `*Localizations.of(context)` getters are non-nullable
/// (`nullable-getter: false`), so a locale that no delegate claims leaves the
/// lookup null and the app dies with "Null check operator used on a null
/// value". That is what a city hits when it adds a language and translates
/// most — but not all — of the packages.
///
/// Register these wrappers **after** the real delegates: Flutter picks the
/// first delegate per type whose `isSupported` is true, so real translations
/// (including the app's own, from `gen_extra_l10n`) always win and the wrapper
/// only catches what nobody else covers.
LocalizationsDelegate<T> fallbackLocalizationsDelegate<T>(
  LocalizationsDelegate<T> delegate, {
  Locale fallbackLocale = const Locale('en'),
}) => _FallbackLocalizationsDelegate<T>(delegate, fallbackLocale);

/// Applies [fallbackLocalizationsDelegate] to each of [delegates].
List<LocalizationsDelegate<dynamic>> fallbackLocalizationsDelegates(
  Iterable<LocalizationsDelegate<dynamic>> delegates, {
  Locale fallbackLocale = const Locale('en'),
}) => [
  for (final delegate in delegates)
    _FallbackLocalizationsDelegate<dynamic>(delegate, fallbackLocale),
];

class _FallbackLocalizationsDelegate<T> extends LocalizationsDelegate<T> {
  const _FallbackLocalizationsDelegate(this.inner, this.fallbackLocale);

  final LocalizationsDelegate<T> inner;
  final Locale fallbackLocale;

  @override
  Type get type => inner.type;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<T> load(Locale locale) {
    if (inner.isSupported(locale)) return inner.load(locale);
    // Same guard as above: if the configured fallback isn't supported by
    // this delegate either, use English (every trufi-core package ships it).
    return inner.load(
      inner.isSupported(fallbackLocale) ? fallbackLocale : const Locale('en'),
    );
  }

  @override
  bool shouldReload(_FallbackLocalizationsDelegate<T> old) =>
      old.inner != inner || old.fallbackLocale != fallbackLocale;

  @override
  String toString() => 'FallbackLocalizations(${inner.type}, $fallbackLocale)';
}

List<LocalizationsDelegate<dynamic>> fallbackFrameworkLocalizationsDelegates({
  Locale fallbackLocale = const Locale('en'),
}) {
  // The fallback itself must be a language Flutter ships — an app whose
  // default locale IS the city language (e.g. defaultLocale: qu) would
  // otherwise crash inside the fallback that exists to prevent crashes.
  final safe = GlobalMaterialLocalizations.delegate.isSupported(fallbackLocale)
      ? fallbackLocale
      : const Locale('en');
  return [
    _FallbackMaterialLocalizationsDelegate(safe),
    _FallbackWidgetsLocalizationsDelegate(safe),
    _FallbackCupertinoLocalizationsDelegate(safe),
  ];
}

class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate(this.fallbackLocale);

  final Locale fallbackLocale;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(fallbackLocale);

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) =>
      old.fallbackLocale != fallbackLocale;

  @override
  String toString() => 'FallbackMaterialLocalizations($fallbackLocale)';
}

class _FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _FallbackWidgetsLocalizationsDelegate(this.fallbackLocale);

  final Locale fallbackLocale;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(fallbackLocale);

  @override
  bool shouldReload(_FallbackWidgetsLocalizationsDelegate old) =>
      old.fallbackLocale != fallbackLocale;

  @override
  String toString() => 'FallbackWidgetsLocalizations($fallbackLocale)';
}

class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate(this.fallbackLocale);

  final Locale fallbackLocale;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(fallbackLocale);

  @override
  bool shouldReload(_FallbackCupertinoLocalizationsDelegate old) =>
      old.fallbackLocale != fallbackLocale;

  @override
  String toString() => 'FallbackCupertinoLocalizations($fallbackLocale)';
}

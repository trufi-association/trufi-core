// Regenerates this app's extra-language localizations (beyond trufi-core's
// built-in en/es/de) into lib/l10n/.
//
// For every trufi-core *Localizations abstract class, and every language under
// tools/l10n/i18n/<lang>/<namespace>.arb, this emits:
//   * lib/l10n/l10n_<lang>.dart — concrete subclasses (translations inlined) +
//     delegates + a <lang>LocalizationsDelegates list,
//   * lib/l10n/l10n.dart — a single `L10n` entry point (L10n.delegates).
//
// trufi-core is NEVER modified: Flutter uses the first delegate per type whose
// isSupported(locale) is true, and the core delegates return false for these
// languages, so the app's delegates (registered via extraLocalizationsDelegates)
// win. gen-l10n can't subclass another package's classes — hence this script.
//
// It resolves trufi-core from .dart_tool/package_config.json, so it works for
// any app consuming trufi-core (git/pub), wherever the packages are cached.
//
// Usage (from the app root, after `flutter pub get`):
//   dart run trufi_core_utils:gen_extra_l10n
import 'dart:convert';
import 'dart:io';

const _skipDirs = {'build', '.dart_tool', '.git', 'example', 'ios', 'android', 'test'};

String _cap(String s) => s[0].toUpperCase() + s.substring(1);

String _esc(String s) => s
    .replaceAll('\\', '\\\\')
    .replaceAll("'", "\\'")
    .replaceAll(r'$', '\\\$')
    .replaceAll('\r', '')
    .replaceAll('\n', '\\n');

String dartLit(String s) => "'${_esc(s)}'";

String dartMethodLit(String s, List<String> args) {
  var body = _esc(s);
  for (final a in args) {
    body = body.replaceAll('{$a}', '\${$a}');
  }
  return "'$body'";
}

class _Type {
  final String cls;
  final String ns;
  final String import;
  final List<String> getters;
  final List<({String name, String params})> methods;
  _Type(this.cls, this.ns, this.import, this.getters, this.methods);
}

/// Resolves the lib/ dirs of every trufi_core_* package from package_config.json.
List<Directory> _trufiCoreLibDirs() {
  final configFile = File('.dart_tool/package_config.json');
  if (!configFile.existsSync()) {
    stderr.writeln('No .dart_tool/package_config.json — run `flutter pub get` first.');
    exit(1);
  }
  final cfg = jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  final base = configFile.absolute.uri;
  final dirs = <Directory>[];
  for (final pkg in (cfg['packages'] as List).cast<Map<String, dynamic>>()) {
    final name = pkg['name'] as String;
    if (!name.startsWith('trufi_core')) continue;
    var rootStr = pkg['rootUri'] as String;
    if (!rootStr.endsWith('/')) rootStr += '/'; // treat as directory before join
    final root = base.resolve(rootStr);
    final libUri = root.resolve((pkg['packageUri'] as String?) ?? 'lib/');
    final dir = Directory.fromUri(libUri);
    if (dir.existsSync()) dirs.add(dir);
  }
  return dirs;
}

/// Walks a package lib dir for abstract *_localizations.dart files, returning
/// (file, packageName, importPath) for each.
void _collectAbstract(Directory libDir, String pkg, List<_Type> out, Map<String, Map<String, Map<String, String>>> byNs, List<String> langs) {
  void walk(Directory d) {
    List<FileSystemEntity> entries;
    try {
      entries = d.listSync(followLinks: false);
    } catch (_) {
      return;
    }
    for (final e in entries) {
      final name = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
      if (e is Directory) {
        if (_skipDirs.contains(name)) continue;
        walk(e);
      } else if (e is File &&
          name.endsWith('_localizations.dart') &&
          !name.endsWith('_extra.dart') &&
          !name.endsWith('_runtime.dart')) {
        final src = e.readAsStringSync();
        final cls = RegExp(r'abstract class (\w+)').firstMatch(src)?.group(1);
        if (cls == null) continue;
        final ns = name.replaceAll('_localizations.dart', '');
        if (byNs[ns] == null) continue; // no translation shipped for this namespace
        final rel = e.path.replaceAll('\\', '/').split('/lib/').last;
        final getters = RegExp(r'^\s*String\s+get\s+(\w+);', multiLine: true)
            .allMatches(src)
            .map((m) => m.group(1)!)
            .toList();
        final methods = RegExp(r'^\s*String\s+(\w+)\(([^)]*)\)\s*;', multiLine: true)
            .allMatches(src)
            .map((m) => (name: m.group(1)!, params: m.group(2)!.trim()))
            .toList();
        out.add(_Type(cls, ns, "import 'package:$pkg/$rel';", getters, methods));
      }
    }
  }

  walk(libDir);
}

void main() {
  // 1. Auto-discover languages + load translations: namespace -> lang -> {k:v}
  final i18nRoot = Directory('tools/l10n/i18n');
  if (!i18nRoot.existsSync()) {
    stderr.writeln('Missing tools/l10n/i18n (run from the app root).');
    exit(1);
  }
  final langs = i18nRoot
      .listSync()
      .whereType<Directory>()
      .map((d) => d.uri.pathSegments.where((s) => s.isNotEmpty).last)
      .toList()
    ..sort();

  final byNs = <String, Map<String, Map<String, String>>>{};
  for (final lang in langs) {
    for (final f in Directory('tools/l10n/i18n/$lang').listSync().whereType<File>()) {
      if (!f.path.endsWith('.arb')) continue;
      final ns = f.uri.pathSegments.last.replaceAll('.arb', '');
      final m = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      (byNs[ns] ??= {})[lang] = {
        for (final e in m.entries)
          if (!e.key.startsWith('@')) e.key: e.value.toString(),
      };
    }
  }

  // 2. Find trufi-core abstract localization classes (via package_config).
  final types = <_Type>[];
  for (final libDir in _trufiCoreLibDirs()) {
    final pkg = libDir.parent.uri.pathSegments.where((s) => s.isNotEmpty).last;
    _collectAbstract(libDir, pkg, types, byNs, langs);
  }
  types.sort((a, b) => a.cls.compareTo(b.cls));

  Directory('lib/l10n').createSync(recursive: true);
  final langListNames = <String>[];

  // 3. One file per language.
  for (final lang in langs) {
    final imports = <String>{};
    final body = StringBuffer();
    final delegateRefs = <String>[];

    for (final t in types) {
      final kv = byNs[t.ns]![lang];
      if (kv == null) continue;
      imports.add(t.import);
      final clsL = '${t.cls}${_cap(lang)}';
      final del = '_${clsL}Delegate';

      body
        ..writeln()
        ..writeln('/// ${t.cls} in `$lang`.')
        ..writeln('class $clsL extends ${t.cls} {')
        ..writeln("  $clsL([String locale = '$lang']) : super(locale);");
      for (final g in t.getters) {
        body
          ..writeln('  @override')
          ..writeln('  String get $g => ${dartLit(kv[g] ?? '')};');
      }
      for (final m in t.methods) {
        final args = m.params
            .split(',')
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .map((p) => p.split(RegExp(r'\s+')).last)
            .toList();
        body
          ..writeln('  @override')
          ..writeln(
              '  String ${m.name}(${m.params}) => ${dartMethodLit(kv[m.name] ?? '', args)};');
      }
      body.writeln('}');

      body
        ..writeln()
        ..writeln('class $del extends LocalizationsDelegate<${t.cls}> {')
        ..writeln('  const $del();')
        ..writeln('  @override')
        ..writeln("  bool isSupported(Locale locale) => locale.languageCode == '$lang';")
        ..writeln('  @override')
        ..writeln('  Future<${t.cls}> load(Locale locale) =>')
        ..writeln('      SynchronousFuture<${t.cls}>($clsL());')
        ..writeln('  @override')
        ..writeln('  bool shouldReload($del old) => false;')
        ..writeln('}');

      delegateRefs.add('const $del()');
    }

    final listName = '${lang}LocalizationsDelegates';
    langListNames.add(listName);
    final f = StringBuffer()
      ..writeln('// GENERATED by trufi_core_utils:gen_extra_l10n — do not edit by hand.')
      ..writeln('// Edit tools/l10n/i18n/$lang/*.arb and re-run: dart run trufi_core_utils:gen_extra_l10n')
      ..writeln('//')
      ..writeln('// `$lang` localizations for this app (concrete classes, translations')
      ..writeln('// inlined). trufi-core ships en/es/de; this is added app-side.')
      ..writeln('// ignore_for_file: type=lint, implementation_imports')
      ..writeln()
      ..writeln("import 'package:flutter/foundation.dart';")
      ..writeln("import 'package:flutter/widgets.dart';")
      ..writeln((imports.toList()..sort()).join('\n'))
      ..write(body.toString())
      ..writeln()
      ..writeln('/// All `$lang` localization delegates for this app.')
      ..writeln('const List<LocalizationsDelegate<dynamic>> $listName = [')
      ..writeln('  ${delegateRefs.join(',\n  ')},')
      ..writeln('];');
    File('lib/l10n/l10n_$lang.dart').writeAsStringSync(f.toString());
    stdout.writeln('✓ lib/l10n/l10n_$lang.dart (${delegateRefs.length} types)');
  }

  // 4. Single entry point: L10n.delegates.
  final agg = StringBuffer()
    ..writeln('// GENERATED by trufi_core_utils:gen_extra_l10n — do not edit by hand.')
    ..writeln('//')
    ..writeln("// Single entry point for this app's extra-language localizations.")
    ..writeln('// Pass `L10n.delegates` to')
    ..writeln('// AppConfiguration(extraLocalizationsDelegates: L10n.delegates).')
    ..writeln('// ignore_for_file: type=lint')
    ..writeln()
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln(langs.map((l) => "import 'l10n_$l.dart';").join('\n'))
    ..writeln()
    ..writeln('class L10n {')
    ..writeln('  const L10n._();')
    ..writeln('  /// All extra-language localization delegates this app ships.')
    ..writeln('  static const List<LocalizationsDelegate<dynamic>> delegates = [')
    ..writeln(langListNames.map((n) => '    ...$n,').join('\n'))
    ..writeln('  ];')
    ..writeln('}');
  File('lib/l10n/l10n.dart').writeAsStringSync(agg.toString());
  stdout.writeln('✓ lib/l10n/l10n.dart (L10n.delegates: ${langs.join(", ")})');
}

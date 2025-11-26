import 'package:flutter/material.dart';

/// A ChangeNotifier that manages the language state and provides methods
/// to load and change the locale.
class LanguageProvider extends ChangeNotifier {
  LanguageProvider() {
    _language = LanguageModel(
      id: '00000000-0000-0000-0000-000000000001',
      name: 'English',
      langCode: 'en_US',
      createdOn: DateTime.now(),
    );
    _languages = [];
  }

  late LanguageModel _language;
  late List<LanguageModel> _languages;

  LanguageModel get language => _language;
  List<LanguageModel> get languages => _languages;

  List<Locale> get supportedLocales => _languages
      .map(
        (value) =>
            Locale(value.langCode.split('_')[0], value.langCode.split('_')[1]),
      )
      .toList();

  /// Loads the initial state of the language feature.
  Future<void> loadState(String? languageId) async {
    _languages = [
      LanguageModel(
        id: 'id',
        langCode: 'langCode',
        name: 'name',
        createdOn: DateTime.now(),
      ),
    ];
    _language = _languages.firstWhere(
      (value) => value.id == languageId,
      orElse: () => _language,
    );
    notifyListeners();
  }

  /// Changes the current locale if different.
  void changeLocale(LanguageModel newLanguage) {
    if (newLanguage.langCode != _language.langCode) {
      _language = newLanguage;
      notifyListeners();
    }
  }
}

/// Represents a language model.
/// Contains information about a specific language, including its ID, code, and name.
class LanguageModel {
  const LanguageModel({
    required this.id,
    required this.langCode,
    required this.name,
    required this.createdOn,
  });

  /// Creates a `LanguageModel` instance from a JSON object.
  /// The [json] parameter is the decoded JSON map representing the language data.
  factory LanguageModel.fromJson(json) => LanguageModel(
    id: json[keyId],
    langCode: json[keyLangCode],
    name: json[keyName],
    createdOn: DateTime.parse(json[keyCreatedOn]),
  );

  /// Creates a `LanguageModel` with default values for testing or placeholder purposes.
  factory LanguageModel.fromScratch() => LanguageModel(
    id: 'id',
    langCode: 'langCode',
    name: 'name',
    createdOn: DateTime.now(),
  );

  static const keyId = 'id';
  static const keyLangCode = 'langCode';
  static const keyName = 'name';
  static const keyCreatedOn = 'createdOn';

  final String id;
  final String langCode;
  final String name;
  final DateTime createdOn;

  /// Retrieves the value associated with the given key from the language model.
  /// The [key] parameter specifies the key to retrieve the value for. Returns the corresponding value if found, otherwise null.
  dynamic getValueFromKey(String key) => {
    keyId: id,
    keyLangCode: langCode,
    keyName: name,
    keyCreatedOn: createdOn,
  }[key];

  /// Returns a `Locale` object representing the language of this model.
  /// Extracts the language code from the `langCode` property and creates a `Locale` instance.
  Locale get locale => Locale(langCode.split('_')[0], langCode.split('_')[1]);
}

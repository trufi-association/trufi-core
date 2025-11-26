class TranslatedStringEntity {
  final String? text;
  final String? language;

  const TranslatedStringEntity({this.text, this.language});

  static const String _text = 'text';
  static const String _language = 'language';

  factory TranslatedStringEntity.fromJson(Map<String, dynamic> json) =>
      TranslatedStringEntity(text: json[_text], language: json[_language]);

  Map<String, dynamic> toJson() => {_text: text, _language: language};
}

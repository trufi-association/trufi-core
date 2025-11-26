import 'package:trufi_core/models/translated_string.dart';

class TranslatedString {
  final String? text;
  final String? language;

  const TranslatedString({this.text, this.language});

  factory TranslatedString.fromJson(Map<String, dynamic> json) =>
      TranslatedString(
        text: json['text'].toString(),
        language: json['language'].toString(),
      );

  Map<String, dynamic> toJson() => {'text': text, 'language': language};

  TranslatedStringEntity toTranslatedStringEntity() {
    return TranslatedStringEntity(text: text, language: language);
  }
}

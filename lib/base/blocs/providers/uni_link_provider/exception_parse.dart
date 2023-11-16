class UnilinkParseException implements Exception {
  final String title;
  final String message;
  // This can store the original data that caused the exception, if needed.
  final dynamic sourceData;

  UnilinkParseException(this.title, this.message, [this.sourceData]);

  @override
  String toString() {
    if (sourceData != null) {
      return 'UnilinkParseException: $message\nSource data: $sourceData';
    } else {
      return 'UnilinkParseException: $message';
    }
  }
}

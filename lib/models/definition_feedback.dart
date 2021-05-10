enum FeedBackType { email, url }

class DefinitionFeedBack {
  /// You can selected the type feedback with enum
  /// [type] parameter support {email and url}
  final FeedBackType type;

  /// [body] is you url or email for feedback.
  final String body;

  DefinitionFeedBack(
    this.type,
    this.body,
  );
}

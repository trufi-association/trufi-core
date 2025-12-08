/// Exception thrown when an online request fails.
class FetchOnlineRequestException implements Exception {
  FetchOnlineRequestException(this._innerException);

  final Exception _innerException;

  @override
  String toString() {
    return "Fetch online request exception caused by: ${_innerException.toString()}";
  }
}

/// Exception thrown when an online response is invalid.
class FetchOnlineResponseException implements Exception {
  FetchOnlineResponseException(this._message);

  final String _message;

  @override
  String toString() {
    return "Fetch online response exception: $_message";
  }
}

/// Exception thrown when the user cancels a fetch operation.
class FetchCanceledByUserException implements Exception {
  FetchCanceledByUserException(this._message);

  final String _message;

  @override
  String toString() {
    return "Canceled by user: $_message";
  }
}

/// Exception thrown when the plan fetch fails.
class FetchOnlinePlanException implements Exception {
  FetchOnlinePlanException(this._code, this._message);

  final int _code;
  final String _message;

  int get code => _code;
  String get message => _message;

  @override
  String toString() {
    return "Fetch Online Plan Exception: $_message";
  }
}

/// Exception thrown when a plan fetch is cancelled.
class FetchCancelPlanException implements Exception {
  FetchCancelPlanException();
}

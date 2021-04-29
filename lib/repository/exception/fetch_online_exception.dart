// Exceptions

class FetchOfflineRequestException implements Exception {
  FetchOfflineRequestException(this._innerException);

  final Exception _innerException;

  @override
  String toString() {
    return "Fetch offline request exception caused by: ${_innerException.toString()}";
  }
}

class FetchOfflineResponseException implements Exception {
  FetchOfflineResponseException(this._message);

  final String _message;

  @override
  String toString() {
    return "Fetch offline response exception: $_message";
  }
}

class FetchOnlineRequestException implements Exception {
  FetchOnlineRequestException(this._innerException);

  final Exception _innerException;

  @override
  String toString() {
    return "Fetch online request exception caused by: ${_innerException.toString()}";
  }
}

class FetchOnlineResponseException implements Exception {
  FetchOnlineResponseException(this._message);

  final String _message;

  @override
  String toString() {
    return "Fetch online response exception: $_message";
  }
}

class FetchCanceledByUserException implements Exception {
  FetchCanceledByUserException(this._message);

  final String _message;

  @override
  String toString() {
    return "Canceled by user: $_message";
  }
}

class FetchOnlineCarException implements Exception {
  FetchOnlineCarException(this._message);

  final String _message;

  @override
  String toString() {
    return "Canceled by user: $_message";
  }
}

class FetchOnlinePlanException implements Exception {
  FetchOnlinePlanException(this._message);

  final String _message;

  @override
  String toString() {
    return "Canceled by user: $_message";
  }
}

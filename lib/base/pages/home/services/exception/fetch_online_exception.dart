// Exceptions

// class FetchOfflineRequestException implements Exception {
//   FetchOfflineRequestException(this._innerException);

//   final Exception _innerException;

//   @override
//   String toString() {
//     return "Fetch offline request exception caused by: ${_innerException.toString()}";
//   }
// }

// class FetchOfflineResponseException implements Exception {
//   FetchOfflineResponseException(this._message);

//   final String _message;

//   @override
//   String toString() {
//     return "Fetch offline response exception: $_message";
//   }
// }

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

// class FetchOnlineCarException implements Exception {
//   FetchOnlineCarException(this._code, this._message);

//   final int _code;
//   final String _message;

//   int get code => _code;

//   @override
//   String toString() {
//     return _message;
//   }
// }

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

class FetchCancelPlanException implements Exception {
  FetchCancelPlanException();
}

// class FetchErrorServerException implements Exception {
//   FetchErrorServerException(this._innerException);

//   final Exception _innerException;

//   @override
//   String toString() {
//     return "Fetch error server exception caused by: ${_innerException.toString()}";
//   }
// }

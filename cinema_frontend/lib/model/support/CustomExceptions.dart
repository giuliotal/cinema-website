class CustomException implements Exception {
  final String _message;
  final String _prefix;

  CustomException(this._message, this._prefix);

  String get body {
    return _message;
  }

  String toString() {
    return "$_prefix$_message";
  }
}

class BadRequestException extends CustomException {
  BadRequestException(message) : super(message, "Invalid request: ");
}

class UnauthorizedException extends CustomException {
  UnauthorizedException(message) : super(message, "UnauthorizedException: ");
}
class ServerException extends CustomException {
  ServerException(message) : super(message, "ServerException: ");
}
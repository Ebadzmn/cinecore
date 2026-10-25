class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException(statusCode: $statusCode, code: $code, message: $message)';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network and try again.',
    super.statusCode = 0,
    super.code = 'NETWORK_ERROR',
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = 'Server encounter an error. Please try again later.',
    super.statusCode = 500,
    super.code = 'SERVER_ERROR',
    super.details,
  });
}

class BadRequestException extends AppException {
  const BadRequestException({
    required super.message,
    super.statusCode = 400,
    super.code = 'BAD_REQUEST',
    super.details,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Access forbidden.',
    super.statusCode = 403,
    super.code = 'FORBIDDEN',
    super.details,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Your session has expired. Please login again.',
    super.statusCode = 401,
    super.code = 'UNAUTHORIZED',
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.statusCode = 422,
    super.code = 'VALIDATION_ERROR',
    super.details,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Requested resource not found.',
    super.statusCode = 404,
    super.code = 'NOT_FOUND',
  });
}

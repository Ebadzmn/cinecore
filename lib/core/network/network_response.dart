/// Standardized Network Response Model following Clean Architecture best practices
class NetworkResponse<T> {
  final bool isSuccess;
  final int statusCode;
  final T? data;
  final String? message;
  final String? errorCode;
  final dynamic details;
  final dynamic rawData;

  const NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    this.message,
    this.errorCode,
    this.details,
    this.rawData,
  });

  /// Factory for successful responses
  factory NetworkResponse.success({
    required int statusCode,
    T? data,
    String? message,
    dynamic rawData,
  }) {
    return NetworkResponse<T>(
      isSuccess: true,
      statusCode: statusCode,
      data: data,
      message: message,
      rawData: rawData,
    );
  }

  /// Factory for failed responses
  factory NetworkResponse.failure({
    required int statusCode,
    String? message,
    String? errorCode,
    dynamic details,
    dynamic rawData,
  }) {
    return NetworkResponse<T>(
      isSuccess: false,
      statusCode: statusCode,
      message: message ?? 'Network request failed',
      errorCode: errorCode ?? 'NETWORK_ERROR',
      details: details,
      rawData: rawData,
    );
  }

  @override
  String toString() {
    return 'NetworkResponse(isSuccess: $isSuccess, statusCode: $statusCode, message: $message, data: $data)';
  }
}

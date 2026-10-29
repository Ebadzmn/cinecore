import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'api_exceptions.dart';
import 'network_logger_interceptor.dart';
import 'network_response.dart';

/// Clean Architecture Network Caller implementing best-practice HTTP operations
class NetworkCaller {
  static final NetworkCaller _instance = NetworkCaller._internal();
  factory NetworkCaller() => _instance;

  late final Dio _dio;
  String? _authToken;

  NetworkCaller._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Platform': 'flutter',
        },
      ),
    );

    _setupInterceptors();
  }

  static void Function()? onUnauthorized;

  Dio get dio => _dio;
  String? get authToken => _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void _setupInterceptors() {
    // 1. Auth & Dynamic Config Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.baseUrl = ApiConstants.baseUrl;
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401 && _authToken != null && _authToken!.isNotEmpty) {
            final path = error.requestOptions.path;
            if (!path.contains('/auth/login') && !path.contains('/auth/register')) {
              onUnauthorized?.call();
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 2. Beautiful Production-grade Logger Interceptor
    _dio.interceptors.add(NetworkLoggerInterceptor());
  }

  /// Generic GET Request
  Future<NetworkResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    return _executeRequest<T>(
      () => _dio.get(path, queryParameters: queryParameters, options: options),
      fromJson: fromJson,
    );
  }

  /// Generic POST Request
  Future<NetworkResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    return _executeRequest<T>(
      () => _dio.post(path, data: data, queryParameters: queryParameters, options: options),
      fromJson: fromJson,
    );
  }

  /// Generic PATCH Request
  Future<NetworkResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    return _executeRequest<T>(
      () => _dio.patch(path, data: data, queryParameters: queryParameters, options: options),
      fromJson: fromJson,
    );
  }

  /// Generic PUT Request
  Future<NetworkResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    return _executeRequest<T>(
      () => _dio.put(path, data: data, queryParameters: queryParameters, options: options),
      fromJson: fromJson,
    );
  }

  /// Generic DELETE Request
  Future<NetworkResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    return _executeRequest<T>(
      () => _dio.delete(path, data: data, queryParameters: queryParameters, options: options),
      fromJson: fromJson,
    );
  }

  /// Direct raw execution returning Dio Response
  Future<Response> getRaw(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response> postRaw(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response> putRaw(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response> patchRaw(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response> deleteRaw(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// Central request executor with typed error handling & JSON parsing
  Future<NetworkResponse<T>> _executeRequest<T>(
    Future<Response> Function() requestFunc, {
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await requestFunc();
      final statusCode = response.statusCode ?? 200;
      final rawData = response.data;

      T? parsedData;
      String? message;

      if (rawData is Map<String, dynamic>) {
        message = rawData['message']?.toString();
        final payloadData = rawData.containsKey('data') ? rawData['data'] : rawData;
        if (fromJson != null && payloadData != null) {
          parsedData = fromJson(payloadData);
        } else if (payloadData is T) {
          parsedData = payloadData;
        }
      } else if (fromJson != null && rawData != null) {
        parsedData = fromJson(rawData);
      } else if (rawData is T) {
        parsedData = rawData;
      }

      return NetworkResponse<T>.success(
        statusCode: statusCode,
        data: parsedData,
        message: message,
        rawData: rawData,
      );
    } on DioException catch (e) {
      final appException = handleDioError(e);
      return NetworkResponse<T>.failure(
        statusCode: appException.statusCode ?? 500,
        message: appException.message,
        errorCode: appException.code,
        details: appException.details,
        rawData: e.response?.data,
      );
    } catch (e) {
      return NetworkResponse<T>.failure(
        statusCode: 500,
        message: e.toString(),
        errorCode: 'UNEXPECTED_ERROR',
      );
    }
  }

  /// Maps DioException to typed domain AppException
  AppException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final responseData = error.response?.data;
        String message = 'Something went wrong';
        String code = 'API_ERROR';
        dynamic details;

        if (responseData is Map<String, dynamic>) {
          message = responseData['message']?.toString() ?? message;
          if (responseData['code'] != null) {
            code = responseData['code'].toString();
          }
          if (responseData['error'] is Map) {
            code = responseData['error']['code']?.toString() ?? code;
            details = responseData['error']['details'];
          } else if (responseData['details'] != null) {
            details = responseData['details'];
            if (details is List && details.isNotEmpty) {
              final firstItem = details.first;
              if (firstItem is Map && firstItem['message'] != null) {
                message = firstItem['message'].toString();
              }
            }
          }
        }

        if (statusCode == 400) {
          return BadRequestException(message: message, statusCode: statusCode, code: code, details: details);
        } else if (statusCode == 401) {
          return UnauthorizedException(message: message, statusCode: statusCode, code: code);
        } else if (statusCode == 403) {
          return ForbiddenException(message: message, statusCode: statusCode, code: code, details: details);
        } else if (statusCode == 404) {
          return NotFoundException(message: message, statusCode: statusCode, code: code);
        } else if (statusCode == 422) {
          return ValidationException(message: message, statusCode: statusCode, code: code, details: details);
        } else {
          return ServerException(message: message, statusCode: statusCode, code: code, details: details);
        }
      default:
        return AppException(message: error.message ?? 'Unknown network error');
    }
  }
}

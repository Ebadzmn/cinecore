import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'api_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  String? _authToken;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Platform': 'flutter',
        },
      ),
    );

    _setupInterceptors();
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          developer.log('--> ${options.method} ${options.uri}', name: 'ApiClient');
          if (options.data != null) {
            developer.log('Data: ${options.data}', name: 'ApiClient');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log('<-- ${response.statusCode} ${response.requestOptions.uri}', name: 'ApiClient');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          developer.log('<-- ERROR: ${error.message} (${error.response?.statusCode})', name: 'ApiClient');
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String message = 'Something went wrong';
        String code = 'API_ERROR';
        dynamic details;

        if (responseData is Map<String, dynamic>) {
          message = responseData['message']?.toString() ?? message;
          if (responseData['error'] is Map) {
            code = responseData['error']['code']?.toString() ?? code;
            details = responseData['error']['details'];
          }
        }

        if (statusCode == 401) {
          return UnauthorizedException(message: message, statusCode: statusCode, code: code);
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

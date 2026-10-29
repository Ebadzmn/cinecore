import 'package:dio/dio.dart';
import 'network_caller.dart';

/// Facade for NetworkCaller ensuring 100% backward compatibility
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final NetworkCaller _caller = NetworkCaller();

  ApiClient._internal();

  Dio get dio => _caller.dio;

  void setAuthToken(String? token) {
    _caller.setAuthToken(token);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _caller.getRaw(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _caller.postRaw(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _caller.putRaw(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _caller.patchRaw(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _caller.deleteRaw(path, data: data, queryParameters: queryParameters, options: options);
  }
}

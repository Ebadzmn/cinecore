import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Production-Grade Dio Interceptor for Logging HTTP Network Traffic
class NetworkLoggerInterceptor extends Interceptor {
  final bool enabled;
  final bool logHeaders;
  final bool logRequestBody;
  final bool logResponseBody;

  NetworkLoggerInterceptor({
    this.enabled = kDebugMode,
    this.logHeaders = true,
    this.logRequestBody = true,
    this.logResponseBody = true,
  });

  static const String _startTimeKey = '_net_start_time';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) return handler.next(options);

    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    final buffer = StringBuffer();
    buffer.writeln('\n┌─── 🚀 [NETWORK REQUEST] ──────────────────────────────────────────');
    buffer.writeln('│ Method: ${options.method.toUpperCase()}');
    buffer.writeln('│ URL:    ${options.uri}');

    if (logHeaders && options.headers.isNotEmpty) {
      final safeHeaders = Map<String, dynamic>.from(options.headers);
      if (safeHeaders.containsKey('Authorization')) {
        final token = safeHeaders['Authorization'].toString();
        if (token.length > 25) {
          safeHeaders['Authorization'] = '${token.substring(0, 15)}...${token.substring(token.length - 6)}';
        }
      }
      buffer.writeln('│ Headers: $safeHeaders');
    }

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query:   ${options.queryParameters}');
    }

    if (logRequestBody && options.data != null) {
      buffer.writeln('│ Body:');
      final formattedBody = _formatData(options.data, maskSensitive: true);
      for (final line in formattedBody.split('\n')) {
        buffer.writeln('│   $line');
      }
    }

    buffer.write('└───────────────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled) return handler.next(response);

    final startTime = response.requestOptions.extra[_startTimeKey] as int?;
    final duration = startTime != null
        ? '${DateTime.now().millisecondsSinceEpoch - startTime}ms'
        : 'unknown';

    final buffer = StringBuffer();
    buffer.writeln('\n┌─── ✅ [NETWORK RESPONSE: ${response.statusCode}] ───────────────────────');
    buffer.writeln('│ URL:      ${response.requestOptions.uri}');
    buffer.writeln('│ Method:   ${response.requestOptions.method.toUpperCase()}');
    buffer.writeln('│ Latency:  $duration');
    buffer.writeln('│ Status:   ${response.statusCode} ${response.statusMessage ?? ''}');

    if (logResponseBody && response.data != null) {
      buffer.writeln('│ Data:');
      final formattedData = _formatData(response.data);
      final lines = formattedData.split('\n');
      // Limit to 40 lines in console to prevent log flooding
      final maxLines = lines.length > 40 ? 40 : lines.length;
      for (var i = 0; i < maxLines; i++) {
        buffer.writeln('│   ${lines[i]}');
      }
      if (lines.length > 40) {
        buffer.writeln('│   ... [${lines.length - 40} more lines truncated]');
      }
    }

    buffer.write('└───────────────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) return handler.next(err);

    final startTime = err.requestOptions.extra[_startTimeKey] as int?;
    final duration = startTime != null
        ? '${DateTime.now().millisecondsSinceEpoch - startTime}ms'
        : 'unknown';

    final buffer = StringBuffer();
    buffer.writeln('\n┌─── ❌ [NETWORK ERROR: ${err.response?.statusCode ?? 'FAIL'}] ─────────────────────────');
    buffer.writeln('│ URL:      ${err.requestOptions.uri}');
    buffer.writeln('│ Method:   ${err.requestOptions.method.toUpperCase()}');
    buffer.writeln('│ Latency:  $duration');
    buffer.writeln('│ Type:     ${err.type}');
    buffer.writeln('│ Message:  ${err.message}');

    if (err.response?.data != null) {
      buffer.writeln('│ Error Body:');
      final formattedError = _formatData(err.response?.data);
      for (final line in formattedError.split('\n')) {
        buffer.writeln('│   $line');
      }
    }

    buffer.write('└───────────────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());

    return handler.next(err);
  }

  /// Pretty-prints JSON/Map data while masking sensitive fields
  String _formatData(dynamic data, {bool maskSensitive = false}) {
    try {
      dynamic process(dynamic input) {
        if (input is Map) {
          final processed = <String, dynamic>{};
          for (final entry in input.entries) {
            final key = entry.key.toString();
            final lowerKey = key.toLowerCase();
            if (maskSensitive &&
                (lowerKey.contains('password') ||
                    lowerKey.contains('secret') ||
                    lowerKey == 'token')) {
              processed[key] = '••••••••';
            } else {
              processed[key] = process(entry.value);
            }
          }
          return processed;
        } else if (input is List) {
          return input.map((item) => process(item)).toList();
        }
        return input;
      }

      final processedData = maskSensitive ? process(data) : data;
      const encoder = JsonEncoder.withIndent('  ');
      if (processedData is Map || processedData is List) {
        return encoder.convert(processedData);
      }
      return processedData.toString();
    } catch (_) {
      return data.toString();
    }
  }
}

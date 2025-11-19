import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Retry Interceptor with exponential backoff
/// Retries failed requests with increasing delays: 1s, 2s, 4s
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on specific error types
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    // Get retry count from request options
    final retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;

    // Check if we've exceeded max retries
    if (retryCount >= maxRetries) {
      return handler.next(err);
    }

    // Calculate delay for this retry attempt
    final delayIndex = retryCount.clamp(0, retryDelays.length - 1);
    final delay = retryDelays[delayIndex];

    debugPrint('Retrying request (attempt ${retryCount + 1}/$maxRetries) after ${delay.inSeconds}s...');

    // Wait for the delay
    await Future.delayed(delay);

    // Update retry count
    err.requestOptions.extra['retry_count'] = retryCount + 1;

    // Retry the request
    try {
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Determine if the error should trigger a retry
  bool _shouldRetry(DioException err) {
    // Don't retry client errors (4xx) except 408 (timeout)
    if (err.response?.statusCode != null) {
      final statusCode = err.response!.statusCode!;
      if (statusCode >= 400 && statusCode < 500 && statusCode != 408) {
        return false;
      }
    }

    // Retry on connection errors, timeouts, and server errors (5xx)
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

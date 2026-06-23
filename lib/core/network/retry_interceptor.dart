import 'dart:io';

import 'package:dio/dio.dart';

/// Reintenta peticiones que fallan por errores de conexión transitorios.
///
/// Caso típico: `HttpException: Connection closed before full header was
/// received`. Ocurre cuando el pool de keep-alive del `HttpClient` reutiliza
/// una conexión que el servidor (p. ej. uvicorn con `--timeout-keep-alive`) ya
/// cerró por inactividad. La conexión está muerta y la primera petición falla,
/// pero un reintento abre una conexión nueva y funciona.
///
/// Solo reintenta métodos idempotentes (GET/HEAD/DELETE/PUT) para no duplicar
/// efectos en POST.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 2,
    this.retryDelay = const Duration(milliseconds: 250),
  });

  final Dio _dio;
  final int maxRetries;
  final Duration retryDelay;

  static const _retryCountKey = 'retry_count';
  static const _idempotentMethods = {'GET', 'HEAD', 'DELETE', 'PUT'};

  bool _isTransient(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.unknown:
        return e.error is HttpException || e.error is SocketException;
      default:
        return false;
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final attempt = (req.extra[_retryCountKey] as int?) ?? 0;
    final isIdempotent = _idempotentMethods.contains(req.method.toUpperCase());

    if (_isTransient(err) && isIdempotent && attempt < maxRetries) {
      req.extra[_retryCountKey] = attempt + 1;
      await Future<void>.delayed(retryDelay);
      try {
        final response = await _dio.fetch<dynamic>(req);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    return handler.next(err);
  }
}

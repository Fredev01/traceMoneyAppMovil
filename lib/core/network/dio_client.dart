import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'api_constants.dart';
import 'retry_interceptor.dart';

class DioClient {
  factory DioClient() => _instance;
  static final DioClient _instance = DioClient._();

  DioClient._()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
            connectTimeout:
                const Duration(milliseconds: ApiConstants.connectTimeoutMs),
            receiveTimeout:
                const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
          ),
        ) {
    // Reintenta errores de conexión transitorios (p. ej. "Connection closed
    // before full header was received" al reusar una conexión keep-alive que el
    // servidor ya cerró). Aplica en debug y release.
    dio.interceptors.add(RetryInterceptor(dio));

    if (kDebugMode) {
      // El backend local sirve HTTPS con certificado autofirmado, que Android
      // rechaza por defecto (HandshakeException / CERTIFICATE_VERIFY_FAILED).
      // Solo en debug aceptamos ese certificado; en release nunca se omite TLS.
      // `idleTimeout` se mantiene por debajo del keep-alive de uvicorn (~5s)
      // para que sea el cliente quien suelte la conexión ociosa primero y no
      // tome una ya cerrada por el servidor.
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () => HttpClient()
          ..badCertificateCallback = ((cert, host, port) => true)
          ..idleTimeout = const Duration(seconds: 3),
      );

      // Loguea request/response/errores para diagnosticar parseo en desarrollo.
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  final Dio dio;
}

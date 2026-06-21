import 'package:dio/dio.dart';
import 'api_constants.dart';

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
        );

  final Dio dio;
}

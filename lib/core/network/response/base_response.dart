import 'package:trace_money/core/network/response/api_error_detail.dart';

class BaseResponse {
  final ApiErrorDetail? detail;

  const BaseResponse({this.detail});

  factory BaseResponse.fromJson(Map<String, dynamic> json) => BaseResponse(
        detail: json['detail'] is Map<String, dynamic>
            ? ApiErrorDetail.fromJson(json['detail'] as Map<String, dynamic>)
            : null,
      );

  bool get isError => detail != null;
}

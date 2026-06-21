import 'package:trace_money/core/network/response/api_error_detail.dart';
import 'package:trace_money/core/network/response/base_response.dart';

class CreatedResponse extends BaseResponse {
  final String id;

  const CreatedResponse({required this.id, super.detail});

  factory CreatedResponse.fromJson(Map<String, dynamic> json) => CreatedResponse(
        id: json['id'] as String,
        detail: json['detail'] is Map<String, dynamic>
            ? ApiErrorDetail.fromJson(json['detail'] as Map<String, dynamic>)
            : null,
      );
}

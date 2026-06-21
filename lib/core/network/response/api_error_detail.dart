class ApiErrorDetail {
  final String code;
  final String message;

  const ApiErrorDetail({required this.code, required this.message});

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) => ApiErrorDetail(
        code: json['code'] as String,
        message: json['message'] as String,
      );
}

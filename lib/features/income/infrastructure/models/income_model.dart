import '../../domain/entities/income.dart';
import '../../domain/entities/income_source.dart';

class IncomeModel {
  final String id;
  final String amount;
  final String source;
  final String? note;
  final String incomeDate;
  final String createdAt;
  final String? accountId;

  const IncomeModel({
    required this.id,
    required this.amount,
    required this.source,
    this.note,
    required this.incomeDate,
    required this.createdAt,
    this.accountId,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) => IncomeModel(
        id: json['id'] as String,
        amount: json['amount'] as String,
        source: json['source'] as String,
        note: json['note'] as String?,
        incomeDate: json['income_date'] as String,
        createdAt: json['created_at'] as String,
        accountId: json['account_id'] as String?,
      );

  Income toEntity() => Income(
        id: id,
        amount: amount,
        source: IncomeSourceX.fromApiString(source),
        note: note,
        incomeDate: incomeDate,
        createdAt: createdAt,
        accountId: accountId,
      );
}

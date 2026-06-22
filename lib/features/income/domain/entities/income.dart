import 'income_source.dart';

class Income {
  final String id;
  final String amount;
  final IncomeSource source;
  final String? note;
  final String incomeDate;
  final String createdAt;
  final String? accountId;

  const Income({
    required this.id,
    required this.amount,
    required this.source,
    this.note,
    required this.incomeDate,
    required this.createdAt,
    this.accountId,
  });
}

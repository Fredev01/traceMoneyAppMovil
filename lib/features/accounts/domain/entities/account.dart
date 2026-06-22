import 'account_type.dart';

class Account {
  final String id;
  final AccountType accountType;
  final String bankName;
  final String color;
  final String? creditLimit;
  final int? cutDay;
  final int? paymentDueDay;
  final String createdAt;

  const Account({
    required this.id,
    required this.accountType,
    required this.bankName,
    required this.color,
    this.creditLimit,
    this.cutDay,
    this.paymentDueDay,
    required this.createdAt,
  });
}

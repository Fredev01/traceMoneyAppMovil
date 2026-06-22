import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';

class AccountModel {
  final String id;
  final String accountType;
  final String bankName;
  final String color;
  final String? creditLimit;
  final int? cutDay;
  final int? paymentDueDay;
  final String createdAt;

  const AccountModel({
    required this.id,
    required this.accountType,
    required this.bankName,
    required this.color,
    this.creditLimit,
    this.cutDay,
    this.paymentDueDay,
    required this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        id: json['id'] as String,
        accountType: json['account_type'] as String,
        bankName: json['bank_name'] as String,
        color: json['color'] as String,
        creditLimit: json['credit_limit'] as String?,
        cutDay: json['cut_day'] as int?,
        paymentDueDay: json['payment_due_day'] as int?,
        createdAt: json['created_at'] as String,
      );

  Account toEntity() => Account(
        id: id,
        accountType: AccountTypeX.fromApiString(accountType),
        bankName: bankName,
        color: color,
        creditLimit: creditLimit,
        cutDay: cutDay,
        paymentDueDay: paymentDueDay,
        createdAt: createdAt,
      );
}

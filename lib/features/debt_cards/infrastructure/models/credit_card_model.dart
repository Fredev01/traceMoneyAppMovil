import '../../domain/entities/credit_card.dart';

class CreditCardModel {
  final String id;
  final String bankName;
  final String creditLimit;
  final int cutDay;
  final int paymentDueDay;
  final String color;
  final String createdAt;

  const CreditCardModel({
    required this.id,
    required this.bankName,
    required this.creditLimit,
    required this.cutDay,
    required this.paymentDueDay,
    required this.color,
    required this.createdAt,
  });

  factory CreditCardModel.fromJson(Map<String, dynamic> json) =>
      CreditCardModel(
        id: json['id'] as String,
        bankName: json['bank_name'] as String,
        creditLimit: json['credit_limit'] as String,
        cutDay: json['cut_day'] as int,
        paymentDueDay: json['payment_due_day'] as int,
        color: json['color'] as String,
        createdAt: json['created_at'] as String,
      );

  CreditCard toEntity() => CreditCard(
        id: id,
        bankName: bankName,
        creditLimit: creditLimit,
        cutDay: cutDay,
        paymentDueDay: paymentDueDay,
        color: color,
        createdAt: createdAt,
      );
}

class CreditCard {
  final String id;
  final String bankName;
  final String creditLimit;
  final int cutDay;
  final int paymentDueDay;
  final String color;
  final String createdAt;

  const CreditCard({
    required this.id,
    required this.bankName,
    required this.creditLimit,
    required this.cutDay,
    required this.paymentDueDay,
    required this.color,
    required this.createdAt,
  });
}

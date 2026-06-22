class CreateDebtCardDto {
  final String bankName;
  final String creditLimit;
  final int cutDay;
  final int paymentDueDay;
  final String color;

  const CreateDebtCardDto({
    required this.bankName,
    required this.creditLimit,
    required this.cutDay,
    required this.paymentDueDay,
    required this.color,
  });
}

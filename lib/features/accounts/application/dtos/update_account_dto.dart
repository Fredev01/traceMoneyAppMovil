class UpdateAccountDto {
  final String id;
  final String bankName;
  final String color;
  final String? creditLimit;
  final int? cutDay;
  final int? paymentDueDay;

  const UpdateAccountDto({
    required this.id,
    required this.bankName,
    required this.color,
    this.creditLimit,
    this.cutDay,
    this.paymentDueDay,
  });
}

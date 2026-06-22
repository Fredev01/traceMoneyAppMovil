class CreateAccountDto {
  final String accountType;
  final String bankName;
  final String color;
  final String? creditLimit;
  final int? cutDay;
  final int? paymentDueDay;

  const CreateAccountDto({
    required this.accountType,
    required this.bankName,
    required this.color,
    this.creditLimit,
    this.cutDay,
    this.paymentDueDay,
  });
}

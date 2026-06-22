class CreateIncomeDto {
  final String amount;
  final String source;
  final String incomeDate;
  final String? note;
  final String? accountId;

  const CreateIncomeDto({
    required this.amount,
    required this.source,
    required this.incomeDate,
    this.note,
    this.accountId,
  });
}

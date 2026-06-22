class AssignCapitalDto {
  final String accountId;
  final String amount;
  final String movementDate;
  final String? note;

  const AssignCapitalDto({
    required this.accountId,
    required this.amount,
    required this.movementDate,
    this.note,
  });
}

class TransferDto {
  final String sourceAccountId;
  final String targetAccountId;
  final String amount;
  final String transferDate;
  final String? note;

  const TransferDto({
    required this.sourceAccountId,
    required this.targetAccountId,
    required this.amount,
    required this.transferDate,
    this.note,
  });
}

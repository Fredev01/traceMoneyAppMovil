import 'movement_type.dart';

class AccountMovement {
  final String id;
  final String accountId;
  final MovementType movementType;
  final String amount;
  final String movementDate;
  final String? note;
  final String? relatedAccountId;

  const AccountMovement({
    required this.id,
    required this.accountId,
    required this.movementType,
    required this.amount,
    required this.movementDate,
    this.note,
    this.relatedAccountId,
  });
}

import '../../domain/entities/account_movement.dart';
import '../../domain/entities/movement_type.dart';

class AccountMovementModel {
  final String id;
  final String accountId;
  final String movementType;
  final String amount;
  final String movementDate;
  final String? note;
  final String? relatedAccountId;

  const AccountMovementModel({
    required this.id,
    required this.accountId,
    required this.movementType,
    required this.amount,
    required this.movementDate,
    this.note,
    this.relatedAccountId,
  });

  factory AccountMovementModel.fromJson(Map<String, dynamic> json) =>
      AccountMovementModel(
        id: json['id'] as String,
        accountId: json['account_id'] as String,
        movementType: json['movement_type'] as String,
        amount: json['amount'] as String,
        movementDate: json['movement_date'] as String,
        note: json['note'] as String?,
        relatedAccountId: json['related_account_id'] as String?,
      );

  AccountMovement toEntity() => AccountMovement(
        id: id,
        accountId: accountId,
        movementType: MovementTypeX.fromApiString(movementType),
        amount: amount,
        movementDate: movementDate,
        note: note,
        relatedAccountId: relatedAccountId,
      );
}

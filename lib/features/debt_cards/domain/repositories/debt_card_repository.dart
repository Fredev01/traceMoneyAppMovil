import 'package:fpdart/fpdart.dart';
import '../entities/credit_card.dart';
import '../failures/debt_card_failure.dart';

abstract interface class DebtCardRepository {
  Future<Either<DebtCardFailure, List<CreditCard>>> getDebtCards();

  Future<Either<DebtCardFailure, String>> createDebtCard({
    required String bankName,
    required String creditLimit,
    required int cutDay,
    required int paymentDueDay,
    required String color,
  });

  Future<Either<DebtCardFailure, void>> updateDebtCard({
    required String id,
    required String bankName,
    required String creditLimit,
    required int cutDay,
    required int paymentDueDay,
    required String color,
  });
}

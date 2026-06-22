import 'package:fpdart/fpdart.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/failures/debt_card_failure.dart';
import '../../domain/repositories/debt_card_repository.dart';

class GetDebtCardsUseCase {
  final DebtCardRepository _repository;
  const GetDebtCardsUseCase(this._repository);

  Future<Either<DebtCardFailure, List<CreditCard>>> call() =>
      _repository.getDebtCards();
}

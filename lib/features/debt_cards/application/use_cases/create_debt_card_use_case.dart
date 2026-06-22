import 'package:fpdart/fpdart.dart';
import '../../domain/failures/debt_card_failure.dart';
import '../../domain/repositories/debt_card_repository.dart';
import '../dtos/create_debt_card_dto.dart';

class CreateDebtCardUseCase {
  final DebtCardRepository _repository;
  const CreateDebtCardUseCase(this._repository);

  Future<Either<DebtCardFailure, String>> call(CreateDebtCardDto dto) =>
      _repository.createDebtCard(
        bankName: dto.bankName,
        creditLimit: dto.creditLimit,
        cutDay: dto.cutDay,
        paymentDueDay: dto.paymentDueDay,
        color: dto.color,
      );
}

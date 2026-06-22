import 'package:fpdart/fpdart.dart';
import '../../domain/failures/debt_card_failure.dart';
import '../../domain/repositories/debt_card_repository.dart';
import '../dtos/update_debt_card_dto.dart';

class UpdateDebtCardUseCase {
  final DebtCardRepository _repository;
  const UpdateDebtCardUseCase(this._repository);

  Future<Either<DebtCardFailure, void>> call(UpdateDebtCardDto dto) =>
      _repository.updateDebtCard(
        id: dto.id,
        bankName: dto.bankName,
        creditLimit: dto.creditLimit,
        cutDay: dto.cutDay,
        paymentDueDay: dto.paymentDueDay,
        color: dto.color,
      );
}

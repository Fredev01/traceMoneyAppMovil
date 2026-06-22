import 'package:fpdart/fpdart.dart';
import '../../domain/failures/income_failure.dart';
import '../../domain/repositories/income_repository.dart';
import '../dtos/update_income_dto.dart';

class UpdateIncomeUseCase {
  final IncomeRepository _repository;
  const UpdateIncomeUseCase(this._repository);

  Future<Either<IncomeFailure, void>> call(UpdateIncomeDto dto) =>
      _repository.updateIncome(
        id: dto.id,
        amount: dto.amount,
        source: dto.source,
        incomeDate: dto.incomeDate,
        note: dto.note,
        accountId: dto.accountId,
      );
}

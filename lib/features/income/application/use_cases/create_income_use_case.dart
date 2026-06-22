import 'package:fpdart/fpdart.dart';
import '../../domain/failures/income_failure.dart';
import '../../domain/repositories/income_repository.dart';
import '../dtos/create_income_dto.dart';

class CreateIncomeUseCase {
  final IncomeRepository _repository;
  const CreateIncomeUseCase(this._repository);

  Future<Either<IncomeFailure, String>> call(CreateIncomeDto dto) =>
      _repository.createIncome(
        amount: dto.amount,
        source: dto.source,
        incomeDate: dto.incomeDate,
        note: dto.note,
        accountId: dto.accountId,
      );
}

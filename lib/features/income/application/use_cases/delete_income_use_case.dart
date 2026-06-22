import 'package:fpdart/fpdart.dart';
import '../../domain/failures/income_failure.dart';
import '../../domain/repositories/income_repository.dart';

class DeleteIncomeUseCase {
  final IncomeRepository _repository;
  const DeleteIncomeUseCase(this._repository);

  Future<Either<IncomeFailure, void>> call(String id) =>
      _repository.deleteIncome(id);
}

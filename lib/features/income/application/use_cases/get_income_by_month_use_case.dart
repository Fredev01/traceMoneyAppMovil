import 'package:fpdart/fpdart.dart';
import '../../domain/entities/income.dart';
import '../../domain/failures/income_failure.dart';
import '../../domain/repositories/income_repository.dart';

class GetIncomeByMonthUseCase {
  final IncomeRepository _repository;
  const GetIncomeByMonthUseCase(this._repository);

  Future<Either<IncomeFailure, List<Income>>> call({
    required int year,
    required int month,
  }) =>
      _repository.getIncomeByMonth(year: year, month: month);
}

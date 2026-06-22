import 'package:fpdart/fpdart.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';
import '../dtos/assign_capital_dto.dart';

class AssignCapitalUseCase {
  final AccountRepository _repository;
  const AssignCapitalUseCase(this._repository);

  Future<Either<AccountFailure, void>> call(AssignCapitalDto dto) =>
      _repository.assignCapital(
        accountId: dto.accountId,
        amount: dto.amount,
        movementDate: dto.movementDate,
        note: dto.note,
      );
}

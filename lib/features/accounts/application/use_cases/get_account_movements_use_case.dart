import 'package:fpdart/fpdart.dart';
import '../../domain/entities/account_movement.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';

class GetAccountMovementsUseCase {
  final AccountRepository _repository;
  const GetAccountMovementsUseCase(this._repository);

  Future<Either<AccountFailure, List<AccountMovement>>> call(
          String accountId) =>
      _repository.getAccountMovements(accountId);
}

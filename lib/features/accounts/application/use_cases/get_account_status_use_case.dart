import 'package:fpdart/fpdart.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';

class GetAccountStatusUseCase {
  final AccountRepository _repository;
  const GetAccountStatusUseCase(this._repository);

  Future<Either<AccountFailure, AccountStatus>> call(String accountId) =>
      _repository.getAccountStatus(accountId);
}

import 'package:fpdart/fpdart.dart';
import '../../domain/entities/account.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';

class GetAccountsUseCase {
  final AccountRepository _repository;
  const GetAccountsUseCase(this._repository);

  Future<Either<AccountFailure, List<Account>>> call() =>
      _repository.getAccounts();
}

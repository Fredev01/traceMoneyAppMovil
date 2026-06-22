import 'package:fpdart/fpdart.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';

class DeleteAccountUseCase {
  final AccountRepository _repository;
  const DeleteAccountUseCase(this._repository);

  Future<Either<AccountFailure, void>> call(String id) =>
      _repository.deleteAccount(id);
}

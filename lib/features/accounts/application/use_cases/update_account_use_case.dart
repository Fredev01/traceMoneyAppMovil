import 'package:fpdart/fpdart.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';
import '../dtos/update_account_dto.dart';

class UpdateAccountUseCase {
  final AccountRepository _repository;
  const UpdateAccountUseCase(this._repository);

  Future<Either<AccountFailure, void>> call(UpdateAccountDto dto) =>
      _repository.updateAccount(
        id: dto.id,
        bankName: dto.bankName,
        color: dto.color,
        creditLimit: dto.creditLimit,
        cutDay: dto.cutDay,
        paymentDueDay: dto.paymentDueDay,
      );
}

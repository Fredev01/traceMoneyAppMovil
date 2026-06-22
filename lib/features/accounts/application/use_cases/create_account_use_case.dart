import 'package:fpdart/fpdart.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';
import '../dtos/create_account_dto.dart';

class CreateAccountUseCase {
  final AccountRepository _repository;
  const CreateAccountUseCase(this._repository);

  Future<Either<AccountFailure, String>> call(CreateAccountDto dto) =>
      _repository.createAccount(
        accountType: dto.accountType,
        bankName: dto.bankName,
        color: dto.color,
        creditLimit: dto.creditLimit,
        cutDay: dto.cutDay,
        paymentDueDay: dto.paymentDueDay,
      );
}

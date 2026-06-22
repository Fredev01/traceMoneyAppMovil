import 'package:fpdart/fpdart.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';
import '../dtos/transfer_dto.dart';

class TransferUseCase {
  final AccountRepository _repository;
  const TransferUseCase(this._repository);

  Future<Either<AccountFailure, void>> call(TransferDto dto) =>
      _repository.transfer(
        sourceAccountId: dto.sourceAccountId,
        targetAccountId: dto.targetAccountId,
        amount: dto.amount,
        transferDate: dto.transferDate,
        note: dto.note,
      );
}

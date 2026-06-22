import 'package:fpdart/fpdart.dart';
import '../entities/account.dart';
import '../entities/account_status.dart';
import '../entities/account_movement.dart';
import '../failures/account_failure.dart';

abstract interface class AccountRepository {
  Future<Either<AccountFailure, List<Account>>> getAccounts();

  Future<Either<AccountFailure, String>> createAccount({
    required String accountType,
    required String bankName,
    required String color,
    String? creditLimit,
    int? cutDay,
    int? paymentDueDay,
  });

  Future<Either<AccountFailure, void>> updateAccount({
    required String id,
    required String bankName,
    required String color,
    String? creditLimit,
    int? cutDay,
    int? paymentDueDay,
  });

  Future<Either<AccountFailure, void>> deleteAccount(String id);

  Future<Either<AccountFailure, void>> assignCapital({
    required String accountId,
    required String amount,
    required String movementDate,
    String? note,
  });

  Future<Either<AccountFailure, void>> transfer({
    required String sourceAccountId,
    required String targetAccountId,
    required String amount,
    required String transferDate,
    String? note,
  });

  Future<Either<AccountFailure, AccountStatus>> getAccountStatus(String id);

  Future<Either<AccountFailure, List<AccountMovement>>> getAccountMovements(
      String id);
}

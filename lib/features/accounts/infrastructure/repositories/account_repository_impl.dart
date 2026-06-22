import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_movement.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource _remote;
  const AccountRepositoryImpl(this._remote);

  AccountFailure _mapDio(DioException e) {
    if (e.response?.statusCode == 404) return const AccountNotFound();
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const AccountNetworkFailure();
    }
    final msg = (e.response?.data?['detail'] as Map?)?['message'] as String? ??
        'Error del servidor.';
    return AccountServerFailure(msg);
  }

  @override
  Future<Either<AccountFailure, List<Account>>> getAccounts() async {
    try {
      final models = await _remote.getAccounts();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(AccountServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<AccountFailure, String>> createAccount({
    required String accountType,
    required String bankName,
    required String color,
    String? creditLimit,
    int? cutDay,
    int? paymentDueDay,
  }) async {
    try {
      final id = await _remote.createAccount({
        'account_type': accountType,
        'bank_name': bankName,
        'color': color,
        'credit_limit': creditLimit,
        'cut_day': cutDay,
        'payment_due_day': paymentDueDay,
      });
      return Right(id);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(AccountServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<AccountFailure, void>> updateAccount({
    required String id,
    required String bankName,
    required String color,
    String? creditLimit,
    int? cutDay,
    int? paymentDueDay,
  }) async {
    try {
      await _remote.updateAccount(id, {
        'bank_name': bankName,
        'color': color,
        'credit_limit': creditLimit,
        'cut_day': cutDay,
        'payment_due_day': paymentDueDay,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(AccountServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<AccountFailure, void>> deleteAccount(String id) async {
    try {
      await _remote.deleteAccount(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(AccountServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<AccountFailure, void>> assignCapital({
    required String accountId,
    required String amount,
    required String movementDate,
    String? note,
  }) async {
    try {
      await _remote.assignCapital(accountId, {
        'amount': amount,
        'movement_date': movementDate,
        'note': note,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(AccountServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<AccountFailure, void>> transfer({
    required String sourceAccountId,
    required String targetAccountId,
    required String amount,
    required String transferDate,
    String? note,
  }) async {
    try {
      await _remote.transfer(sourceAccountId, {
        'target_account_id': targetAccountId,
        'amount': amount,
        'transfer_date': transferDate,
        'note': note,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(AccountServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<AccountFailure, AccountStatus>> getAccountStatus(
      String id) async {
    try {
      final model = await _remote.getAccountStatus(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(AccountServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<AccountFailure, List<AccountMovement>>> getAccountMovements(
      String id) async {
    try {
      final models = await _remote.getAccountMovements(id);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(AccountServerFailure('Error inesperado.'));
    }
  }
}

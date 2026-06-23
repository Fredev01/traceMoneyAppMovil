import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/income.dart';
import '../../domain/failures/income_failure.dart';
import '../../domain/repositories/income_repository.dart';
import '../datasources/income_remote_data_source.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeRemoteDataSource _remote;
  const IncomeRepositoryImpl(this._remote);

  IncomeFailure _mapDio(DioException e) {
    if (e.response?.statusCode == 404) return const IncomeNotFound();
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const IncomeNetworkFailure();
    }
    final msg = (e.response?.data?['detail'] as Map?)?['message'] as String? ??
        'Error del servidor.';
    return IncomeServerFailure(msg);
  }

  @override
  Future<Either<IncomeFailure, List<Income>>> getIncomeByMonth({
    required int year,
    required int month,
  }) async {
    try {
      final models = await _remote.getIncomeByMonth(year, month);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e, st) {
      log('getIncomeByMonth parse error', error: e, stackTrace: st);
      return const Left(IncomeServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<IncomeFailure, String>> createIncome({
    required String amount,
    required String source,
    required String incomeDate,
    String? note,
    String? accountId,
  }) async {
    try {
      final id = await _remote.createIncome({
        'amount': amount,
        'source': source,
        'income_date': incomeDate,
        'note': note,
        'account_id': accountId,
      });
      return Right(id);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(IncomeServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<IncomeFailure, void>> updateIncome({
    required String id,
    required String amount,
    required String source,
    required String incomeDate,
    String? note,
    String? accountId,
  }) async {
    try {
      await _remote.updateIncome(id, {
        'amount': amount,
        'source': source,
        'income_date': incomeDate,
        'note': note,
        'account_id': accountId,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(IncomeServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<IncomeFailure, void>> deleteIncome(String id) async {
    try {
      await _remote.deleteIncome(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(IncomeServerFailure('Error inesperado.'));
    }
  }
}

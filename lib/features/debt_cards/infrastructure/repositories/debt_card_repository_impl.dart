import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/failures/debt_card_failure.dart';
import '../../domain/repositories/debt_card_repository.dart';
import '../datasources/debt_card_remote_data_source.dart';

class DebtCardRepositoryImpl implements DebtCardRepository {
  final DebtCardRemoteDataSource _remote;
  const DebtCardRepositoryImpl(this._remote);

  DebtCardFailure _mapDio(DioException e) {
    if (e.response?.statusCode == 404) return const DebtCardNotFound();
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const DebtCardNetworkFailure();
    }
    final msg = (e.response?.data?['detail'] as Map?)?['message'] as String? ??
        'Error del servidor.';
    return DebtCardServerFailure(msg);
  }

  @override
  Future<Either<DebtCardFailure, List<CreditCard>>> getDebtCards() async {
    try {
      final models = await _remote.getDebtCards();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e, st) {
      log('getDebtCards parse error', error: e, stackTrace: st);
      return const Left(DebtCardServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<DebtCardFailure, String>> createDebtCard({
    required String bankName,
    required String creditLimit,
    required int cutDay,
    required int paymentDueDay,
    required String color,
  }) async {
    try {
      final id = await _remote.createDebtCard({
        'bank_name': bankName,
        'credit_limit': creditLimit,
        'cut_day': cutDay,
        'payment_due_day': paymentDueDay,
        'color': color,
      });
      return Right(id);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(DebtCardServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<DebtCardFailure, void>> updateDebtCard({
    required String id,
    required String bankName,
    required String creditLimit,
    required int cutDay,
    required int paymentDueDay,
    required String color,
  }) async {
    try {
      await _remote.updateDebtCard(id, {
        'bank_name': bankName,
        'credit_limit': creditLimit,
        'cut_day': cutDay,
        'payment_due_day': paymentDueDay,
        'color': color,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(DebtCardServerFailure('Error inesperado.'));
    }
  }
}

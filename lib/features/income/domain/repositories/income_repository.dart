import 'package:fpdart/fpdart.dart';
import '../entities/income.dart';
import '../failures/income_failure.dart';

abstract interface class IncomeRepository {
  Future<Either<IncomeFailure, List<Income>>> getIncomeByMonth({
    required int year,
    required int month,
  });

  Future<Either<IncomeFailure, String>> createIncome({
    required String amount,
    required String source,
    required String incomeDate,
    String? note,
    String? accountId,
  });

  Future<Either<IncomeFailure, void>> updateIncome({
    required String id,
    required String amount,
    required String source,
    required String incomeDate,
    String? note,
    String? accountId,
  });

  Future<Either<IncomeFailure, void>> deleteIncome(String id);
}

import 'package:trace_money/core/error/failure.dart';

sealed class IncomeFailure extends Failure {
  const IncomeFailure(super.message);
}

class IncomeNotFound extends IncomeFailure {
  const IncomeNotFound([super.message = 'El ingreso no existe.']);
}

class IncomeNetworkFailure extends IncomeFailure {
  const IncomeNetworkFailure(
      [super.message = 'Error de red al acceder a ingresos.']);
}

class IncomeServerFailure extends IncomeFailure {
  const IncomeServerFailure(super.message);
}

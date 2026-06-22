import 'package:trace_money/core/error/failure.dart';

sealed class DebtCardFailure extends Failure {
  const DebtCardFailure(super.message);
}

class DebtCardNotFound extends DebtCardFailure {
  const DebtCardNotFound([super.message = 'La tarjeta no existe.']);
}

class DebtCardNetworkFailure extends DebtCardFailure {
  const DebtCardNetworkFailure(
      [super.message = 'Error de red al acceder a tarjetas.']);
}

class DebtCardServerFailure extends DebtCardFailure {
  const DebtCardServerFailure(super.message);
}

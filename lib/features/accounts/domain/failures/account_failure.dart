import 'package:trace_money/core/error/failure.dart';

sealed class AccountFailure extends Failure {
  const AccountFailure(super.message);
}

class AccountNotFound extends AccountFailure {
  const AccountNotFound([super.message = 'La cuenta no existe.']);
}

class AccountNetworkFailure extends AccountFailure {
  const AccountNetworkFailure(
      [super.message = 'Error de red al acceder a cuentas.']);
}

class AccountServerFailure extends AccountFailure {
  const AccountServerFailure(super.message);
}

class AccountValidationFailure extends AccountFailure {
  const AccountValidationFailure(super.message);
}

sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Error de red. Verifica tu conexión.']);
}

class ServerFailure extends Failure {
  final int? statusCode;
  final String? code;

  const ServerFailure(super.message, {this.statusCode, this.code});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'El recurso no existe.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Error inesperado.']);
}

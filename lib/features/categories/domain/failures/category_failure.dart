import 'package:trace_money/core/error/failure.dart';

sealed class CategoryFailure extends Failure {
  const CategoryFailure(super.message);
}

class CategoryNotFound extends CategoryFailure {
  const CategoryNotFound([super.message = 'La categoría no existe.']);
}

class CategoryNetworkFailure extends CategoryFailure {
  const CategoryNetworkFailure(
      [super.message = 'Error de red al acceder a categorías.']);
}

class CategoryServerFailure extends CategoryFailure {
  const CategoryServerFailure(super.message);
}

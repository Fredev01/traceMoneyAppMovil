import 'package:fpdart/fpdart.dart';
import '../../domain/entities/category.dart';
import '../../domain/failures/category_failure.dart';
import '../../domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository _repository;
  const GetCategoriesUseCase(this._repository);

  Future<Either<CategoryFailure, List<Category>>> call() =>
      _repository.getCategories();
}

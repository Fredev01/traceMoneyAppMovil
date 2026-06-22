import 'package:fpdart/fpdart.dart';
import '../../domain/failures/category_failure.dart';
import '../../domain/repositories/category_repository.dart';
import '../dtos/create_category_dto.dart';

class CreateCategoryUseCase {
  final CategoryRepository _repository;
  const CreateCategoryUseCase(this._repository);

  Future<Either<CategoryFailure, String>> call(CreateCategoryDto dto) =>
      _repository.createCategory(
        name: dto.name,
        color: dto.color,
        parentId: dto.parentId,
      );
}

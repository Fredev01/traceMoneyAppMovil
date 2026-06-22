import 'package:fpdart/fpdart.dart';
import '../../domain/failures/category_failure.dart';
import '../../domain/repositories/category_repository.dart';
import '../dtos/update_category_dto.dart';

class UpdateCategoryUseCase {
  final CategoryRepository _repository;
  const UpdateCategoryUseCase(this._repository);

  Future<Either<CategoryFailure, void>> call(UpdateCategoryDto dto) =>
      _repository.updateCategory(
        id: dto.id,
        name: dto.name,
        color: dto.color,
      );
}

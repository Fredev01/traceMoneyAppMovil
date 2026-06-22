import 'package:fpdart/fpdart.dart';
import '../entities/category.dart';
import '../failures/category_failure.dart';

abstract interface class CategoryRepository {
  Future<Either<CategoryFailure, List<Category>>> getCategories();

  Future<Either<CategoryFailure, String>> createCategory({
    required String name,
    required String color,
    String? parentId,
  });

  Future<Either<CategoryFailure, void>> updateCategory({
    required String id,
    required String name,
    required String color,
  });
}

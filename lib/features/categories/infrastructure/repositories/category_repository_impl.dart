import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/category.dart';
import '../../domain/failures/category_failure.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remote;
  const CategoryRepositoryImpl(this._remote);

  CategoryFailure _mapDio(DioException e) {
    if (e.response?.statusCode == 404) return const CategoryNotFound();
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const CategoryNetworkFailure();
    }
    final msg = (e.response?.data?['detail'] as Map?)?['message'] as String? ??
        'Error del servidor.';
    return CategoryServerFailure(msg);
  }

  @override
  Future<Either<CategoryFailure, List<Category>>> getCategories() async {
    try {
      final models = await _remote.getCategories();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(CategoryServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<CategoryFailure, String>> createCategory({
    required String name,
    required String color,
    String? parentId,
  }) async {
    try {
      final id = await _remote
          .createCategory({'name': name, 'color': color, 'parent_id': parentId});
      return Right(id);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(CategoryServerFailure('Error inesperado.'));
    }
  }

  @override
  Future<Either<CategoryFailure, void>> updateCategory({
    required String id,
    required String name,
    required String color,
  }) async {
    try {
      await _remote.updateCategory(id, {'name': name, 'color': color});
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (_) {
      return const Left(CategoryServerFailure('Error inesperado.'));
    }
  }
}

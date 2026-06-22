import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/dtos/create_category_dto.dart';
import '../../application/dtos/update_category_dto.dart';
import '../../application/use_cases/create_category_use_case.dart';
import '../../application/use_cases/get_categories_use_case.dart';
import '../../application/use_cases/update_category_use_case.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUseCase _getCategories;
  final CreateCategoryUseCase _createCategory;
  final UpdateCategoryUseCase _updateCategory;

  CategoriesCubit(
    this._getCategories,
    this._createCategory,
    this._updateCategory,
  ) : super(const CategoriesInitial());

  Future<void> loadCategories() async {
    emit(const CategoriesLoading());
    final result = await _getCategories();
    result.fold(
      (f) => emit(CategoriesError(f.message)),
      (cats) => emit(CategoriesLoaded(cats)),
    );
  }

  Future<void> createCategory(CreateCategoryDto dto) async {
    emit(const CategoryFormLoading());
    final result = await _createCategory(dto);
    result.fold(
      (f) => emit(CategoryFormError(f.message)),
      (_) => emit(const CategoryFormSuccess()),
    );
  }

  Future<void> updateCategory(UpdateCategoryDto dto) async {
    emit(const CategoryFormLoading());
    final result = await _updateCategory(dto);
    result.fold(
      (f) => emit(CategoryFormError(f.message)),
      (_) => emit(const CategoryFormSuccess()),
    );
  }
}

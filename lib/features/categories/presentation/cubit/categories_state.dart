import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();
  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;
  const CategoriesLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class CategoriesError extends CategoriesState {
  final String message;
  const CategoriesError(this.message);
  @override
  List<Object?> get props => [message];
}

class CategoryFormLoading extends CategoriesState {
  const CategoryFormLoading();
}

class CategoryFormSuccess extends CategoriesState {
  const CategoryFormSuccess();
}

class CategoryFormError extends CategoriesState {
  final String message;
  const CategoryFormError(this.message);
  @override
  List<Object?> get props => [message];
}

import '../../domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? parentId;
  final String color;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    required this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        parentId: json['parent_id'] as String?,
        color: json['color'] as String,
      );

  Category toEntity() =>
      Category(id: id, name: name, parentId: parentId, color: color);
}

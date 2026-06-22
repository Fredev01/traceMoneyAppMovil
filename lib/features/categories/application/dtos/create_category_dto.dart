class CreateCategoryDto {
  final String name;
  final String color;
  final String? parentId;

  const CreateCategoryDto({
    required this.name,
    required this.color,
    this.parentId,
  });
}

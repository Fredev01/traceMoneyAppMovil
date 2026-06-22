class Category {
  final String id;
  final String name;
  final String? parentId;
  final String color;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
    required this.color,
  });
}

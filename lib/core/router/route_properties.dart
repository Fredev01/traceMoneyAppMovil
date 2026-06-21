class RouteProperties {
  final String name;
  final String path;
  final String? pathRoot;

  const RouteProperties({
    required this.name,
    required this.path,
    this.pathRoot,
  });

  String get fullPath => pathRoot != null ? '$pathRoot/$path' : path;
}

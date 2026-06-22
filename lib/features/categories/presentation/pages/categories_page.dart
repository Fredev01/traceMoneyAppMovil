import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import 'category_form_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) => switch (state) {
          CategoriesInitial() => const SizedBox.shrink(),
          CategoriesLoading() || CategoryFormLoading() =>
            const Center(child: CircularProgressIndicator()),
          CategoriesError(:final message) ||
          CategoryFormError(:final message) =>
            Center(child: Text(message)),
          CategoriesLoaded(:final categories) when categories.isEmpty =>
            const Center(child: Text('Sin categorías. Crea una con el botón +')),
          CategoriesLoaded(:final categories) =>
            _CategoryTree(categories: categories),
          CategoryFormSuccess() => const SizedBox.shrink(),
        },
      ),
    );
  }

  void _openForm(BuildContext context, Category? edit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoriesCubit>(),
        child: CategoryFormPage(editCategory: edit),
      ),
    );
  }
}

class _CategoryTree extends StatelessWidget {
  final List<Category> categories;
  const _CategoryTree({required this.categories});

  @override
  Widget build(BuildContext context) {
    final roots = categories.where((c) => c.parentId == null).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: roots.length,
      itemBuilder: (context, i) {
        final root = roots[i];
        final children =
            categories.where((c) => c.parentId == root.id).toList();
        return _CategoryGroup(parent: root, children: children);
      },
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  final Category parent;
  final List<Category> children;
  const _CategoryGroup({required this.parent, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryTile(category: parent, isRoot: true),
        ...children.map((c) => Padding(
              padding: const EdgeInsets.only(left: 24),
              child: _CategoryTile(category: c, isRoot: false),
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final bool isRoot;
  const _CategoryTile({required this.category, required this.isRoot});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: isRoot ? 16 : 12,
        backgroundColor: _parseColor(category.color),
      ),
      title: Text(
        category.name,
        style: isRoot
            ? Theme.of(context).textTheme.titleSmall
            : Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.teal;
    }
  }
}

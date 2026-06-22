import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_money/shared/widgets/atoms/app_button.dart';
import 'package:trace_money/shared/widgets/atoms/app_text_field.dart';
import '../../application/dtos/create_category_dto.dart';
import '../../application/dtos/update_category_dto.dart';
import '../../domain/entities/category.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? editCategory;
  const CategoryFormPage({super.key, this.editCategory});

  bool get isEdit => editCategory != null;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _nameCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = widget.editCategory;
    if (c != null) {
      _nameCtrl.text = c.name;
      _colorCtrl.text = c.color;
    } else {
      _colorCtrl.text = '#10b981';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<CategoriesCubit>();
    if (widget.isEdit) {
      cubit.updateCategory(UpdateCategoryDto(
        id: widget.editCategory!.id,
        name: _nameCtrl.text.trim(),
        color: _colorCtrl.text.trim(),
      ));
    } else {
      cubit.createCategory(CreateCategoryDto(
        name: _nameCtrl.text.trim(),
        color: _colorCtrl.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state is CategoryFormSuccess) Navigator.of(context).pop();
        if (state is CategoryFormError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isEdit ? 'Editar categoría' : 'Nueva categoría',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            AppTextField(controller: _nameCtrl, label: 'Nombre'),
            const SizedBox(height: 16),
            AppTextField(controller: _colorCtrl, label: 'Color (hex)'),
            const SizedBox(height: 24),
            BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) => AppButton(
                label: widget.isEdit ? 'Guardar' : 'Crear',
                isLoading: state is CategoryFormLoading,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

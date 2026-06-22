import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_money/shared/widgets/atoms/app_button.dart';
import 'package:trace_money/shared/widgets/atoms/app_text_field.dart';
import '../../application/dtos/create_income_dto.dart';
import '../../application/dtos/update_income_dto.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/income_source.dart';
import '../bloc/income_bloc.dart';
import '../bloc/income_event.dart';
import '../bloc/income_state.dart';

class IncomeFormPage extends StatefulWidget {
  final Income? editIncome;
  const IncomeFormPage({super.key, this.editIncome});

  bool get isEdit => editIncome != null;

  @override
  State<IncomeFormPage> createState() => _IncomeFormPageState();
}

class _IncomeFormPageState extends State<IncomeFormPage> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  IncomeSource _source = IncomeSource.sueldo;

  @override
  void initState() {
    super.initState();
    final i = widget.editIncome;
    if (i != null) {
      _amountCtrl.text = i.amount;
      _noteCtrl.text = i.note ?? '';
      _dateCtrl.text = i.incomeDate;
      _source = i.source;
    } else {
      final now = DateTime.now();
      _dateCtrl.text =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final bloc = context.read<IncomeBloc>();
    if (widget.isEdit) {
      bloc.add(IncomeUpdated(UpdateIncomeDto(
        id: widget.editIncome!.id,
        amount: _amountCtrl.text.trim(),
        source: _source.toApiString(),
        incomeDate: _dateCtrl.text.trim(),
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      )));
    } else {
      bloc.add(IncomeCreated(CreateIncomeDto(
        amount: _amountCtrl.text.trim(),
        source: _source.toApiString(),
        incomeDate: _dateCtrl.text.trim(),
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IncomeBloc, IncomeState>(
      listener: (context, state) {
        if (state is IncomeMutationSuccess) context.pop();
        if (state is IncomeMutationError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Editar ingreso' : 'Nuevo ingreso'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _amountCtrl,
                label: 'Monto',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<IncomeSource>(
                initialValue: _source,
                decoration: const InputDecoration(labelText: 'Fuente'),
                items: IncomeSource.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.label),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _source = v!),
              ),
              const SizedBox(height: 16),
              AppTextField(controller: _dateCtrl, label: 'Fecha (YYYY-MM-DD)'),
              const SizedBox(height: 16),
              AppTextField(controller: _noteCtrl, label: 'Nota (opcional)'),
              const SizedBox(height: 32),
              BlocBuilder<IncomeBloc, IncomeState>(
                builder: (context, state) => AppButton(
                  label: widget.isEdit ? 'Guardar cambios' : 'Registrar ingreso',
                  isLoading: state is IncomeMutationLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

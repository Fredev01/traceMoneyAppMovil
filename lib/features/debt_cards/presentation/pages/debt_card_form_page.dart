import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_money/shared/widgets/atoms/app_button.dart';
import 'package:trace_money/shared/widgets/atoms/app_text_field.dart';
import '../../application/dtos/create_debt_card_dto.dart';
import '../../application/dtos/update_debt_card_dto.dart';
import '../../domain/entities/credit_card.dart';
import '../cubit/debt_cards_cubit.dart';
import '../cubit/debt_cards_state.dart';

class DebtCardFormPage extends StatefulWidget {
  final CreditCard? editCard;
  const DebtCardFormPage({super.key, this.editCard});

  bool get isEdit => editCard != null;

  @override
  State<DebtCardFormPage> createState() => _DebtCardFormPageState();
}

class _DebtCardFormPageState extends State<DebtCardFormPage> {
  final _bankNameCtrl = TextEditingController();
  final _creditLimitCtrl = TextEditingController();
  final _cutDayCtrl = TextEditingController();
  final _paymentDueDayCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = widget.editCard;
    if (c != null) {
      _bankNameCtrl.text = c.bankName;
      _creditLimitCtrl.text = c.creditLimit;
      _cutDayCtrl.text = c.cutDay.toString();
      _paymentDueDayCtrl.text = c.paymentDueDay.toString();
      _colorCtrl.text = c.color;
    } else {
      _colorCtrl.text = '#3b82f6';
    }
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _creditLimitCtrl.dispose();
    _cutDayCtrl.dispose();
    _paymentDueDayCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<DebtCardsCubit>();
    if (widget.isEdit) {
      cubit.updateCard(UpdateDebtCardDto(
        id: widget.editCard!.id,
        bankName: _bankNameCtrl.text.trim(),
        creditLimit: _creditLimitCtrl.text.trim(),
        cutDay: int.tryParse(_cutDayCtrl.text) ?? 1,
        paymentDueDay: int.tryParse(_paymentDueDayCtrl.text) ?? 1,
        color: _colorCtrl.text.trim(),
      ));
    } else {
      cubit.createCard(CreateDebtCardDto(
        bankName: _bankNameCtrl.text.trim(),
        creditLimit: _creditLimitCtrl.text.trim(),
        cutDay: int.tryParse(_cutDayCtrl.text) ?? 1,
        paymentDueDay: int.tryParse(_paymentDueDayCtrl.text) ?? 1,
        color: _colorCtrl.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DebtCardsCubit, DebtCardsState>(
      listener: (context, state) {
        if (state is DebtCardFormSuccess) Navigator.of(context).pop();
        if (state is DebtCardFormError) {
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
              widget.isEdit ? 'Editar tarjeta' : 'Nueva tarjeta',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            AppTextField(controller: _bankNameCtrl, label: 'Banco'),
            const SizedBox(height: 16),
            AppTextField(
              controller: _creditLimitCtrl,
              label: 'Límite de crédito',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _cutDayCtrl,
                    label: 'Día de corte',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _paymentDueDayCtrl,
                    label: 'Día de pago',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(controller: _colorCtrl, label: 'Color (hex)'),
            const SizedBox(height: 24),
            BlocBuilder<DebtCardsCubit, DebtCardsState>(
              builder: (context, state) => AppButton(
                label: widget.isEdit ? 'Guardar' : 'Agregar tarjeta',
                isLoading: state is DebtCardFormLoading,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

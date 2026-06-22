import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_money/shared/widgets/atoms/app_button.dart';
import 'package:trace_money/shared/widgets/atoms/app_text_field.dart';
import '../../application/dtos/create_account_dto.dart';
import '../../application/dtos/update_account_dto.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../bloc/account_form_bloc.dart';
import '../bloc/account_form_event.dart';
import '../bloc/account_form_state.dart';

class AccountFormPage extends StatefulWidget {
  final Account? editAccount;

  const AccountFormPage({super.key, this.editAccount});

  bool get isEdit => editAccount != null;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _bankNameCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _creditLimitCtrl = TextEditingController();
  final _cutDayCtrl = TextEditingController();
  final _paymentDueDayCtrl = TextEditingController();
  AccountType _accountType = AccountType.debito;

  @override
  void initState() {
    super.initState();
    final a = widget.editAccount;
    if (a != null) {
      _bankNameCtrl.text = a.bankName;
      _colorCtrl.text = a.color;
      _creditLimitCtrl.text = a.creditLimit ?? '';
      _cutDayCtrl.text = a.cutDay?.toString() ?? '';
      _paymentDueDayCtrl.text = a.paymentDueDay?.toString() ?? '';
      _accountType = a.accountType;
    } else {
      _colorCtrl.text = '#6366f1';
    }
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _colorCtrl.dispose();
    _creditLimitCtrl.dispose();
    _cutDayCtrl.dispose();
    _paymentDueDayCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final isCredit = _accountType == AccountType.credito;
    final bloc = context.read<AccountFormBloc>();

    if (widget.isEdit) {
      bloc.add(AccountUpdateSubmitted(UpdateAccountDto(
        id: widget.editAccount!.id,
        bankName: _bankNameCtrl.text.trim(),
        color: _colorCtrl.text.trim(),
        creditLimit: isCredit ? _creditLimitCtrl.text.trim() : null,
        cutDay: isCredit ? int.tryParse(_cutDayCtrl.text) : null,
        paymentDueDay:
            isCredit ? int.tryParse(_paymentDueDayCtrl.text) : null,
      )));
    } else {
      bloc.add(AccountCreateSubmitted(CreateAccountDto(
        accountType: _accountType.toApiString(),
        bankName: _bankNameCtrl.text.trim(),
        color: _colorCtrl.text.trim(),
        creditLimit: isCredit ? _creditLimitCtrl.text.trim() : null,
        cutDay: isCredit ? int.tryParse(_cutDayCtrl.text) : null,
        paymentDueDay:
            isCredit ? int.tryParse(_paymentDueDayCtrl.text) : null,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountFormBloc, AccountFormState>(
      listener: (context, state) {
        if (state is AccountFormSuccess) context.pop();
        if (state is AccountFormError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Editar cuenta' : 'Nueva cuenta'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<AccountType>(
                segments: const [
                  ButtonSegment(
                      value: AccountType.debito, label: Text('Débito')),
                  ButtonSegment(
                      value: AccountType.credito, label: Text('Crédito')),
                ],
                selected: {_accountType},
                onSelectionChanged: widget.isEdit
                    ? null
                    : (s) => setState(() => _accountType = s.first),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _bankNameCtrl,
                label: 'Nombre del banco',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _colorCtrl,
                label: 'Color (hex)',
              ),
              if (_accountType == AccountType.credito) ...[
                const SizedBox(height: 16),
                AppTextField(
                  controller: _creditLimitCtrl,
                  label: 'Límite de crédito',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _cutDayCtrl,
                  label: 'Día de corte',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _paymentDueDayCtrl,
                  label: 'Día de pago',
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 32),
              BlocBuilder<AccountFormBloc, AccountFormState>(
                builder: (context, state) => AppButton(
                  label: widget.isEdit ? 'Guardar cambios' : 'Crear cuenta',
                  isLoading: state is AccountFormLoading,
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

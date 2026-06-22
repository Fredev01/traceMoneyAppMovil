import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/use_cases/assign_capital_use_case.dart';
import '../../application/use_cases/create_account_use_case.dart';
import '../../application/use_cases/transfer_use_case.dart';
import '../../application/use_cases/update_account_use_case.dart';
import 'account_form_event.dart';
import 'account_form_state.dart';

class AccountFormBloc extends Bloc<AccountFormEvent, AccountFormState> {
  final CreateAccountUseCase _create;
  final UpdateAccountUseCase _update;
  final AssignCapitalUseCase _assignCapital;
  final TransferUseCase _transfer;

  AccountFormBloc(
    this._create,
    this._update,
    this._assignCapital,
    this._transfer,
  ) : super(const AccountFormInitial()) {
    on<AccountCreateSubmitted>(_onCreate);
    on<AccountUpdateSubmitted>(_onUpdate);
    on<AccountCapitalSubmitted>(_onCapital);
    on<AccountTransferSubmitted>(_onTransfer);
  }

  Future<void> _onCreate(
      AccountCreateSubmitted event, Emitter<AccountFormState> emit) async {
    emit(const AccountFormLoading());
    final result = await _create(event.dto);
    result.fold(
      (f) => emit(AccountFormError(f.message)),
      (_) => emit(const AccountFormSuccess()),
    );
  }

  Future<void> _onUpdate(
      AccountUpdateSubmitted event, Emitter<AccountFormState> emit) async {
    emit(const AccountFormLoading());
    final result = await _update(event.dto);
    result.fold(
      (f) => emit(AccountFormError(f.message)),
      (_) => emit(const AccountFormSuccess()),
    );
  }

  Future<void> _onCapital(
      AccountCapitalSubmitted event, Emitter<AccountFormState> emit) async {
    emit(const AccountFormLoading());
    final result = await _assignCapital(event.dto);
    result.fold(
      (f) => emit(AccountFormError(f.message)),
      (_) => emit(const AccountFormSuccess()),
    );
  }

  Future<void> _onTransfer(
      AccountTransferSubmitted event, Emitter<AccountFormState> emit) async {
    emit(const AccountFormLoading());
    final result = await _transfer(event.dto);
    result.fold(
      (f) => emit(AccountFormError(f.message)),
      (_) => emit(const AccountFormSuccess()),
    );
  }
}

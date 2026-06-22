import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/use_cases/delete_account_use_case.dart';
import '../../application/use_cases/get_accounts_use_case.dart';
import 'accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final GetAccountsUseCase _getAccounts;
  final DeleteAccountUseCase _deleteAccount;

  AccountsCubit(this._getAccounts, this._deleteAccount)
      : super(const AccountsInitial());

  Future<void> loadAccounts() async {
    emit(const AccountsLoading());
    final result = await _getAccounts();
    result.fold(
      (f) => emit(AccountsError(f.message)),
      (accounts) => emit(AccountsLoaded(accounts)),
    );
  }

  Future<bool> deleteAccount(String id) async {
    final result = await _deleteAccount(id);
    return result.fold((_) => false, (_) {
      loadAccounts();
      return true;
    });
  }
}

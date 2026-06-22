import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/use_cases/get_account_movements_use_case.dart';
import '../../application/use_cases/get_account_status_use_case.dart';
import 'account_detail_state.dart';

class AccountDetailCubit extends Cubit<AccountDetailState> {
  final GetAccountStatusUseCase _getStatus;
  final GetAccountMovementsUseCase _getMovements;

  AccountDetailCubit(this._getStatus, this._getMovements)
      : super(const AccountDetailInitial());

  Future<void> loadDetail(String accountId) async {
    emit(const AccountDetailLoading());
    final statusResult = await _getStatus(accountId);
    final movementsResult = await _getMovements(accountId);

    final failure = statusResult.fold((f) => f, (_) => null) ??
        movementsResult.fold((f) => f, (_) => null);

    if (failure != null) {
      emit(AccountDetailError(failure.message));
      return;
    }

    emit(AccountDetailLoaded(
      status: statusResult.getRight().toNullable()!,
      movements: movementsResult.getRight().toNullable()!,
    ));
  }
}

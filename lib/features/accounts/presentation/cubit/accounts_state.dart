import 'package:equatable/equatable.dart';
import '../../domain/entities/account.dart';

sealed class AccountsState extends Equatable {
  const AccountsState();
  @override
  List<Object?> get props => [];
}

class AccountsInitial extends AccountsState {
  const AccountsInitial();
}

class AccountsLoading extends AccountsState {
  const AccountsLoading();
}

class AccountsLoaded extends AccountsState {
  final List<Account> accounts;
  const AccountsLoaded(this.accounts);
  @override
  List<Object?> get props => [accounts];
}

class AccountsError extends AccountsState {
  final String message;
  const AccountsError(this.message);
  @override
  List<Object?> get props => [message];
}

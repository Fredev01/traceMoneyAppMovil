import 'package:equatable/equatable.dart';
import '../../domain/entities/account_movement.dart';
import '../../domain/entities/account_status.dart';

sealed class AccountDetailState extends Equatable {
  const AccountDetailState();
  @override
  List<Object?> get props => [];
}

class AccountDetailInitial extends AccountDetailState {
  const AccountDetailInitial();
}

class AccountDetailLoading extends AccountDetailState {
  const AccountDetailLoading();
}

class AccountDetailLoaded extends AccountDetailState {
  final AccountStatus status;
  final List<AccountMovement> movements;
  const AccountDetailLoaded({required this.status, required this.movements});
  @override
  List<Object?> get props => [status, movements];
}

class AccountDetailError extends AccountDetailState {
  final String message;
  const AccountDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

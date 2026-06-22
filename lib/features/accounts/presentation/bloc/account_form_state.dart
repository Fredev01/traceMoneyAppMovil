import 'package:equatable/equatable.dart';

sealed class AccountFormState extends Equatable {
  const AccountFormState();
  @override
  List<Object?> get props => [];
}

class AccountFormInitial extends AccountFormState {
  const AccountFormInitial();
}

class AccountFormLoading extends AccountFormState {
  const AccountFormLoading();
}

class AccountFormSuccess extends AccountFormState {
  const AccountFormSuccess();
}

class AccountFormError extends AccountFormState {
  final String message;
  const AccountFormError(this.message);
  @override
  List<Object?> get props => [message];
}

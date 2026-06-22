import 'package:equatable/equatable.dart';
import '../../application/dtos/assign_capital_dto.dart';
import '../../application/dtos/create_account_dto.dart';
import '../../application/dtos/transfer_dto.dart';
import '../../application/dtos/update_account_dto.dart';

sealed class AccountFormEvent extends Equatable {
  const AccountFormEvent();
  @override
  List<Object?> get props => [];
}

class AccountCreateSubmitted extends AccountFormEvent {
  final CreateAccountDto dto;
  const AccountCreateSubmitted(this.dto);
  @override
  List<Object?> get props => [dto];
}

class AccountUpdateSubmitted extends AccountFormEvent {
  final UpdateAccountDto dto;
  const AccountUpdateSubmitted(this.dto);
  @override
  List<Object?> get props => [dto];
}

class AccountCapitalSubmitted extends AccountFormEvent {
  final AssignCapitalDto dto;
  const AccountCapitalSubmitted(this.dto);
  @override
  List<Object?> get props => [dto];
}

class AccountTransferSubmitted extends AccountFormEvent {
  final TransferDto dto;
  const AccountTransferSubmitted(this.dto);
  @override
  List<Object?> get props => [dto];
}

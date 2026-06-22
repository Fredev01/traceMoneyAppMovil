import 'package:equatable/equatable.dart';
import '../../application/dtos/create_income_dto.dart';
import '../../application/dtos/update_income_dto.dart';

sealed class IncomeEvent extends Equatable {
  const IncomeEvent();
  @override
  List<Object?> get props => [];
}

class IncomeMonthLoaded extends IncomeEvent {
  final int year;
  final int month;
  const IncomeMonthLoaded({required this.year, required this.month});
  @override
  List<Object?> get props => [year, month];
}

class IncomePreviousMonth extends IncomeEvent {
  const IncomePreviousMonth();
}

class IncomeNextMonth extends IncomeEvent {
  const IncomeNextMonth();
}

class IncomeCreated extends IncomeEvent {
  final CreateIncomeDto dto;
  const IncomeCreated(this.dto);
  @override
  List<Object?> get props => [dto];
}

class IncomeUpdated extends IncomeEvent {
  final UpdateIncomeDto dto;
  const IncomeUpdated(this.dto);
  @override
  List<Object?> get props => [dto];
}

class IncomeDeleted extends IncomeEvent {
  final String id;
  const IncomeDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

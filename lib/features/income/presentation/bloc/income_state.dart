import 'package:equatable/equatable.dart';
import '../../domain/entities/income.dart';

sealed class IncomeState extends Equatable {
  const IncomeState();
  @override
  List<Object?> get props => [];
}

class IncomeInitial extends IncomeState {
  const IncomeInitial();
}

class IncomeLoading extends IncomeState {
  final int year;
  final int month;
  const IncomeLoading({required this.year, required this.month});
  @override
  List<Object?> get props => [year, month];
}

class IncomeLoaded extends IncomeState {
  final List<Income> incomes;
  final int year;
  final int month;
  const IncomeLoaded({
    required this.incomes,
    required this.year,
    required this.month,
  });
  @override
  List<Object?> get props => [incomes, year, month];
}

class IncomeError extends IncomeState {
  final String message;
  final int year;
  final int month;
  const IncomeError({
    required this.message,
    required this.year,
    required this.month,
  });
  @override
  List<Object?> get props => [message, year, month];
}

class IncomeMutationLoading extends IncomeState {
  const IncomeMutationLoading();
}

class IncomeMutationSuccess extends IncomeState {
  const IncomeMutationSuccess();
}

class IncomeMutationError extends IncomeState {
  final String message;
  const IncomeMutationError(this.message);
  @override
  List<Object?> get props => [message];
}

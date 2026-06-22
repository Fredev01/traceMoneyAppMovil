import 'package:equatable/equatable.dart';
import '../../domain/entities/credit_card.dart';

sealed class DebtCardsState extends Equatable {
  const DebtCardsState();
  @override
  List<Object?> get props => [];
}

class DebtCardsInitial extends DebtCardsState {
  const DebtCardsInitial();
}

class DebtCardsLoading extends DebtCardsState {
  const DebtCardsLoading();
}

class DebtCardsLoaded extends DebtCardsState {
  final List<CreditCard> cards;
  const DebtCardsLoaded(this.cards);
  @override
  List<Object?> get props => [cards];
}

class DebtCardsError extends DebtCardsState {
  final String message;
  const DebtCardsError(this.message);
  @override
  List<Object?> get props => [message];
}

class DebtCardFormLoading extends DebtCardsState {
  const DebtCardFormLoading();
}

class DebtCardFormSuccess extends DebtCardsState {
  const DebtCardFormSuccess();
}

class DebtCardFormError extends DebtCardsState {
  final String message;
  const DebtCardFormError(this.message);
  @override
  List<Object?> get props => [message];
}

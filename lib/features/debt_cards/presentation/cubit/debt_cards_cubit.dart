import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/dtos/create_debt_card_dto.dart';
import '../../application/dtos/update_debt_card_dto.dart';
import '../../application/use_cases/create_debt_card_use_case.dart';
import '../../application/use_cases/get_debt_cards_use_case.dart';
import '../../application/use_cases/update_debt_card_use_case.dart';
import 'debt_cards_state.dart';

class DebtCardsCubit extends Cubit<DebtCardsState> {
  final GetDebtCardsUseCase _getDebtCards;
  final CreateDebtCardUseCase _createDebtCard;
  final UpdateDebtCardUseCase _updateDebtCard;

  DebtCardsCubit(this._getDebtCards, this._createDebtCard, this._updateDebtCard)
      : super(const DebtCardsInitial());

  Future<void> loadCards() async {
    emit(const DebtCardsLoading());
    final result = await _getDebtCards();
    result.fold(
      (f) => emit(DebtCardsError(f.message)),
      (cards) => emit(DebtCardsLoaded(cards)),
    );
  }

  Future<void> createCard(CreateDebtCardDto dto) async {
    emit(const DebtCardFormLoading());
    final result = await _createDebtCard(dto);
    result.fold(
      (f) => emit(DebtCardFormError(f.message)),
      (_) => emit(const DebtCardFormSuccess()),
    );
  }

  Future<void> updateCard(UpdateDebtCardDto dto) async {
    emit(const DebtCardFormLoading());
    final result = await _updateDebtCard(dto);
    result.fold(
      (f) => emit(DebtCardFormError(f.message)),
      (_) => emit(const DebtCardFormSuccess()),
    );
  }
}

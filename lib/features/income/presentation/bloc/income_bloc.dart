import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/use_cases/create_income_use_case.dart';
import '../../application/use_cases/delete_income_use_case.dart';
import '../../application/use_cases/get_income_by_month_use_case.dart';
import '../../application/use_cases/update_income_use_case.dart';
import 'income_event.dart';
import 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  final GetIncomeByMonthUseCase _getByMonth;
  final CreateIncomeUseCase _create;
  final UpdateIncomeUseCase _update;
  final DeleteIncomeUseCase _delete;

  int _year = DateTime.now().year;
  int _month = DateTime.now().month;

  IncomeBloc(this._getByMonth, this._create, this._update, this._delete)
      : super(const IncomeInitial()) {
    on<IncomeMonthLoaded>(_onMonthLoaded);
    on<IncomePreviousMonth>(_onPreviousMonth);
    on<IncomeNextMonth>(_onNextMonth);
    on<IncomeCreated>(_onCreate);
    on<IncomeUpdated>(_onUpdate);
    on<IncomeDeleted>(_onDelete);
  }

  Future<void> _onMonthLoaded(
      IncomeMonthLoaded event, Emitter<IncomeState> emit) async {
    _year = event.year;
    _month = event.month;
    await _fetchCurrent(emit);
  }

  Future<void> _onPreviousMonth(
      IncomePreviousMonth event, Emitter<IncomeState> emit) async {
    if (_month == 1) {
      _month = 12;
      _year--;
    } else {
      _month--;
    }
    await _fetchCurrent(emit);
  }

  Future<void> _onNextMonth(
      IncomeNextMonth event, Emitter<IncomeState> emit) async {
    if (_month == 12) {
      _month = 1;
      _year++;
    } else {
      _month++;
    }
    await _fetchCurrent(emit);
  }

  Future<void> _fetchCurrent(Emitter<IncomeState> emit) async {
    emit(IncomeLoading(year: _year, month: _month));
    final result = await _getByMonth(year: _year, month: _month);
    result.fold(
      (f) => emit(IncomeError(message: f.message, year: _year, month: _month)),
      (list) =>
          emit(IncomeLoaded(incomes: list, year: _year, month: _month)),
    );
  }

  Future<void> _onCreate(
      IncomeCreated event, Emitter<IncomeState> emit) async {
    emit(const IncomeMutationLoading());
    final result = await _create(event.dto);
    result.fold(
      (f) => emit(IncomeMutationError(f.message)),
      (_) {
        emit(const IncomeMutationSuccess());
        add(IncomeMonthLoaded(year: _year, month: _month));
      },
    );
  }

  Future<void> _onUpdate(
      IncomeUpdated event, Emitter<IncomeState> emit) async {
    emit(const IncomeMutationLoading());
    final result = await _update(event.dto);
    result.fold(
      (f) => emit(IncomeMutationError(f.message)),
      (_) {
        emit(const IncomeMutationSuccess());
        add(IncomeMonthLoaded(year: _year, month: _month));
      },
    );
  }

  Future<void> _onDelete(
      IncomeDeleted event, Emitter<IncomeState> emit) async {
    emit(const IncomeMutationLoading());
    final result = await _delete(event.id);
    result.fold(
      (f) => emit(IncomeMutationError(f.message)),
      (_) {
        emit(const IncomeMutationSuccess());
        add(IncomeMonthLoaded(year: _year, month: _month));
      },
    );
  }
}

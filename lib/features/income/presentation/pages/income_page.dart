import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_money/router/routes.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/income_source.dart';
import '../bloc/income_bloc.dart';
import '../bloc/income_event.dart';
import '../bloc/income_state.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<IncomeBloc>().add(
          IncomeMonthLoaded(year: now.year, month: now.month),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncomeBloc, IncomeState>(
      builder: (context, state) {
        final (year, month) = switch (state) {
          IncomeLoading(:final year, :final month) => (year, month),
          IncomeLoaded(:final year, :final month) => (year, month),
          IncomeError(:final year, :final month) => (year, month),
          _ => (DateTime.now().year, DateTime.now().month),
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ingresos'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _MonthNav(year: year, month: month),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.goNamed(Routes.incomeNew.name),
            child: const Icon(Icons.add),
          ),
          body: switch (state) {
            IncomeInitial() || IncomeMutationLoading() =>
              const Center(child: CircularProgressIndicator()),
            IncomeLoading() =>
              const Center(child: CircularProgressIndicator()),
            IncomeError(:final message) => Center(child: Text(message)),
            IncomeLoaded(:final incomes) when incomes.isEmpty =>
              const Center(child: Text('Sin ingresos este mes.')),
            IncomeLoaded(:final incomes) => _IncomeList(incomes: incomes),
            IncomeMutationSuccess() =>
              const Center(child: CircularProgressIndicator()),
            IncomeMutationError(:final message) =>
              Center(child: Text(message)),
          },
        );
      },
    );
  }
}

class _MonthNav extends StatelessWidget {
  final int year;
  final int month;
  const _MonthNav({required this.year, required this.month});

  static const _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                context.read<IncomeBloc>().add(const IncomePreviousMonth()),
          ),
          Text('${_months[month - 1]} $year',
              style: Theme.of(context).textTheme.titleSmall),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () =>
                context.read<IncomeBloc>().add(const IncomeNextMonth()),
          ),
        ],
      ),
    );
  }
}

class _IncomeList extends StatelessWidget {
  final List<Income> incomes;
  const _IncomeList({required this.incomes});

  @override
  Widget build(BuildContext context) {
    final total = incomes.fold(
        0.0, (sum, i) => sum + (double.tryParse(i.amount) ?? 0.0));

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            'Total: \$${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: incomes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _IncomeTile(income: incomes[i]),
          ),
        ),
      ],
    );
  }
}

class _IncomeTile extends StatelessWidget {
  final Income income;
  const _IncomeTile({required this.income});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.trending_up),
      title: Text(income.source.label),
      subtitle: Text(income.incomeDate),
      trailing: Text(
        '\$${income.amount}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

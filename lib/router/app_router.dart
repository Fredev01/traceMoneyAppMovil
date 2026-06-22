import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/accounts/domain/entities/account.dart';
import '../features/accounts/domain/repositories/account_repository.dart';
import '../features/accounts/application/use_cases/assign_capital_use_case.dart';
import '../features/accounts/application/use_cases/create_account_use_case.dart';
import '../features/accounts/application/use_cases/delete_account_use_case.dart';
import '../features/accounts/application/use_cases/get_account_movements_use_case.dart';
import '../features/accounts/application/use_cases/get_account_status_use_case.dart';
import '../features/accounts/application/use_cases/get_accounts_use_case.dart';
import '../features/accounts/application/use_cases/transfer_use_case.dart';
import '../features/accounts/application/use_cases/update_account_use_case.dart';
import '../features/accounts/presentation/bloc/account_form_bloc.dart';
import '../features/accounts/presentation/cubit/account_detail_cubit.dart';
import '../features/accounts/presentation/cubit/accounts_cubit.dart';
import '../features/accounts/presentation/pages/account_detail_page.dart';
import '../features/accounts/presentation/pages/account_form_page.dart';
import '../features/accounts/presentation/pages/accounts_page.dart';

import '../features/categories/domain/repositories/category_repository.dart';
import '../features/categories/application/use_cases/create_category_use_case.dart';
import '../features/categories/application/use_cases/get_categories_use_case.dart';
import '../features/categories/application/use_cases/update_category_use_case.dart';
import '../features/categories/presentation/cubit/categories_cubit.dart';
import '../features/categories/presentation/pages/categories_page.dart';

import '../features/income/domain/repositories/income_repository.dart';
import '../features/income/application/use_cases/create_income_use_case.dart';
import '../features/income/application/use_cases/delete_income_use_case.dart';
import '../features/income/application/use_cases/get_income_by_month_use_case.dart';
import '../features/income/application/use_cases/update_income_use_case.dart';
import '../features/income/presentation/bloc/income_bloc.dart';
import '../features/income/presentation/pages/income_form_page.dart';
import '../features/income/presentation/pages/income_page.dart';

import '../features/debt_cards/domain/repositories/debt_card_repository.dart';
import '../features/debt_cards/application/use_cases/create_debt_card_use_case.dart';
import '../features/debt_cards/application/use_cases/get_debt_cards_use_case.dart';
import '../features/debt_cards/application/use_cases/update_debt_card_use_case.dart';
import '../features/debt_cards/presentation/cubit/debt_cards_cubit.dart';
import '../features/debt_cards/presentation/pages/debt_cards_page.dart';

import '../shared/widgets/organisms/app_shell.dart';
import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: Routes.dashboard.path,
  errorBuilder: (context, state) => _ErrorPage(error: state.error),
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // Dashboard
        GoRoute(
          name: Routes.dashboard.name,
          path: Routes.dashboard.path,
          builder: (context, state) => const _Placeholder('Dashboard'),
        ),

        // Accounts
        GoRoute(
          name: Routes.accounts.name,
          path: Routes.accounts.path,
          builder: (context, state) => BlocProvider(
            create: (ctx) => AccountsCubit(
              GetAccountsUseCase(ctx.read<AccountRepository>()),
              DeleteAccountUseCase(ctx.read<AccountRepository>()),
            ),
            child: const AccountsPage(),
          ),
          routes: [
            GoRoute(
              name: Routes.accountNew.name,
              path: Routes.accountNew.path,
              builder: (context, state) => BlocProvider(
                create: (ctx) => AccountFormBloc(
                  CreateAccountUseCase(ctx.read<AccountRepository>()),
                  UpdateAccountUseCase(ctx.read<AccountRepository>()),
                  AssignCapitalUseCase(ctx.read<AccountRepository>()),
                  TransferUseCase(ctx.read<AccountRepository>()),
                ),
                child: const AccountFormPage(),
              ),
            ),
            GoRoute(
              name: Routes.accountDetail.name,
              path: Routes.accountDetail.path,
              builder: (context, state) {
                final accountId = state.pathParameters['accountId']!;
                return BlocProvider(
                  create: (ctx) => AccountDetailCubit(
                    GetAccountStatusUseCase(ctx.read<AccountRepository>()),
                    GetAccountMovementsUseCase(ctx.read<AccountRepository>()),
                  ),
                  child: AccountDetailPage(accountId: accountId),
                );
              },
              routes: [
                GoRoute(
                  name: Routes.accountEdit.name,
                  path: Routes.accountEdit.path,
                  builder: (context, state) {
                    final editAccount = state.extra as Account?;
                    return BlocProvider(
                      create: (ctx) => AccountFormBloc(
                        CreateAccountUseCase(ctx.read<AccountRepository>()),
                        UpdateAccountUseCase(ctx.read<AccountRepository>()),
                        AssignCapitalUseCase(ctx.read<AccountRepository>()),
                        TransferUseCase(ctx.read<AccountRepository>()),
                      ),
                      child: AccountFormPage(editAccount: editAccount),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // Expenses (placeholder + categories)
        GoRoute(
          path: '/expenses',
          redirect: (_, _) => Routes.expensesWeek.fullPath,
          routes: [
            GoRoute(
              name: Routes.expensesWeek.name,
              path: Routes.expensesWeek.path,
              builder: (context, state) =>
                  const _Placeholder('Gastos — Semana'),
            ),
            GoRoute(
              name: Routes.expensesMonth.name,
              path: Routes.expensesMonth.path,
              builder: (context, state) =>
                  const _Placeholder('Gastos — Mes'),
            ),
            GoRoute(
              name: Routes.expenseNew.name,
              path: Routes.expenseNew.path,
              builder: (context, state) =>
                  const _Placeholder('Nuevo Gasto'),
            ),
            GoRoute(
              name: Routes.expenseCategories.name,
              path: Routes.expenseCategories.path,
              builder: (context, state) => BlocProvider(
                create: (ctx) => CategoriesCubit(
                  GetCategoriesUseCase(ctx.read<CategoryRepository>()),
                  CreateCategoryUseCase(ctx.read<CategoryRepository>()),
                  UpdateCategoryUseCase(ctx.read<CategoryRepository>()),
                ),
                child: const CategoriesPage(),
              ),
            ),
          ],
        ),

        // Income
        GoRoute(
          name: Routes.income.name,
          path: Routes.income.path,
          builder: (context, state) => BlocProvider(
            create: (ctx) => IncomeBloc(
              GetIncomeByMonthUseCase(ctx.read<IncomeRepository>()),
              CreateIncomeUseCase(ctx.read<IncomeRepository>()),
              UpdateIncomeUseCase(ctx.read<IncomeRepository>()),
              DeleteIncomeUseCase(ctx.read<IncomeRepository>()),
            ),
            child: const IncomePage(),
          ),
          routes: [
            GoRoute(
              name: Routes.incomeNew.name,
              path: Routes.incomeNew.path,
              builder: (context, state) {
                final editIncome = state.extra as dynamic;
                return BlocProvider(
                  create: (ctx) => IncomeBloc(
                    GetIncomeByMonthUseCase(ctx.read<IncomeRepository>()),
                    CreateIncomeUseCase(ctx.read<IncomeRepository>()),
                    UpdateIncomeUseCase(ctx.read<IncomeRepository>()),
                    DeleteIncomeUseCase(ctx.read<IncomeRepository>()),
                  ),
                  child: IncomeFormPage(editIncome: editIncome),
                );
              },
            ),
          ],
        ),

        // Debts
        GoRoute(
          path: '/debts',
          redirect: (_, _) => Routes.debtCards.fullPath,
          routes: [
            GoRoute(
              name: Routes.debtCards.name,
              path: Routes.debtCards.path,
              builder: (context, state) => BlocProvider(
                create: (ctx) => DebtCardsCubit(
                  GetDebtCardsUseCase(ctx.read<DebtCardRepository>()),
                  CreateDebtCardUseCase(ctx.read<DebtCardRepository>()),
                  UpdateDebtCardUseCase(ctx.read<DebtCardRepository>()),
                ),
                child: const DebtCardsPage(),
              ),
            ),
            GoRoute(
              name: Routes.debtPlans.name,
              path: Routes.debtPlans.path,
              builder: (context, state) =>
                  const _Placeholder('Planes MSI'),
            ),
            GoRoute(
              name: Routes.debtLoans.name,
              path: Routes.debtLoans.path,
              builder: (context, state) =>
                  const _Placeholder('Préstamos'),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _Placeholder extends StatelessWidget {
  final String name;
  const _Placeholder(this.name);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(name)),
        body: Center(
          child: Text(name, style: Theme.of(context).textTheme.headlineMedium),
        ),
      );
}

class _ErrorPage extends StatelessWidget {
  final Exception? error;
  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(
            'Página no encontrada',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
}

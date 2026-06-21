import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/organisms/app_shell.dart';
import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: Routes.dashboard.path,
  errorBuilder: (context, state) => _ErrorPage(error: state.error),
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          name: Routes.dashboard.name,
          path: Routes.dashboard.path,
          builder: (context, state) => const _Placeholder('Dashboard'),
        ),
        GoRoute(
          name: Routes.accounts.name,
          path: Routes.accounts.path,
          builder: (context, state) => const _Placeholder('Cuentas'),
          routes: [
            GoRoute(
              name: Routes.accountNew.name,
              path: Routes.accountNew.path,
              builder: (context, state) => const _Placeholder('Nueva Cuenta'),
            ),
            GoRoute(
              name: Routes.accountDetail.name,
              path: Routes.accountDetail.path,
              builder: (context, state) => const _Placeholder('Detalle Cuenta'),
              routes: [
                GoRoute(
                  name: Routes.accountEdit.name,
                  path: Routes.accountEdit.path,
                  builder: (context, state) =>
                      const _Placeholder('Editar Cuenta'),
                ),
              ],
            ),
          ],
        ),
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
              builder: (context, state) => const _Placeholder('Gastos — Mes'),
            ),
            GoRoute(
              name: Routes.expenseNew.name,
              path: Routes.expenseNew.path,
              builder: (context, state) => const _Placeholder('Nuevo Gasto'),
            ),
          ],
        ),
        GoRoute(
          name: Routes.income.name,
          path: Routes.income.path,
          builder: (context, state) => const _Placeholder('Ingresos'),
          routes: [
            GoRoute(
              name: Routes.incomeNew.name,
              path: Routes.incomeNew.path,
              builder: (context, state) => const _Placeholder('Nuevo Ingreso'),
            ),
          ],
        ),
        GoRoute(
          path: '/debts',
          redirect: (_, _) => Routes.debtPlans.fullPath,
          routes: [
            GoRoute(
              name: Routes.debtCards.name,
              path: Routes.debtCards.path,
              builder: (context, state) =>
                  const _Placeholder('Tarjetas (Deudas)'),
            ),
            GoRoute(
              name: Routes.debtPlans.name,
              path: Routes.debtPlans.path,
              builder: (context, state) => const _Placeholder('Planes MSI'),
            ),
            GoRoute(
              name: Routes.debtLoans.name,
              path: Routes.debtLoans.path,
              builder: (context, state) => const _Placeholder('Préstamos'),
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
  Widget build(BuildContext context) => Center(
        child: Text(name, style: Theme.of(context).textTheme.headlineMedium),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../router/routes.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/accounts')) return 1;
    if (location.startsWith('/expenses')) return 2;
    if (location.startsWith('/income')) return 3;
    if (location.startsWith('/debts')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) => switch (index) {
          0 => context.goNamed(Routes.dashboard.name),
          1 => context.goNamed(Routes.accounts.name),
          2 => context.goNamed(Routes.expensesWeek.name),
          3 => context.goNamed(Routes.income.name),
          4 => context.goNamed(Routes.debtPlans.name),
          _ => null,
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Cuentas',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Gastos',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Ingresos',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Deudas',
          ),
        ],
      ),
    );
  }
}

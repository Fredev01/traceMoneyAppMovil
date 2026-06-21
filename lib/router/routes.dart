import '../core/router/route_properties.dart';

abstract final class Routes {
  // Dashboard
  static const dashboard = RouteProperties(
    name: 'dashboard',
    path: '/dashboard',
  );

  // Accounts
  static const accounts = RouteProperties(
    name: 'accounts',
    path: '/accounts',
  );
  static const accountNew = RouteProperties(
    name: 'accountNew',
    path: 'new',
    pathRoot: '/accounts',
  );
  static const accountDetail = RouteProperties(
    name: 'accountDetail',
    path: ':accountId',
    pathRoot: '/accounts',
  );
  static const accountEdit = RouteProperties(
    name: 'accountEdit',
    path: 'edit',
    pathRoot: '/accounts/:accountId',
  );

  // Expenses
  static const expensesWeek = RouteProperties(
    name: 'expensesWeek',
    path: 'week',
    pathRoot: '/expenses',
  );
  static const expensesMonth = RouteProperties(
    name: 'expensesMonth',
    path: 'month',
    pathRoot: '/expenses',
  );
  static const expenseNew = RouteProperties(
    name: 'expenseNew',
    path: 'new',
    pathRoot: '/expenses',
  );

  // Income
  static const income = RouteProperties(
    name: 'income',
    path: '/income',
  );
  static const incomeNew = RouteProperties(
    name: 'incomeNew',
    path: 'new',
    pathRoot: '/income',
  );

  // Debts
  static const debtCards = RouteProperties(
    name: 'debtCards',
    path: 'cards',
    pathRoot: '/debts',
  );
  static const debtPlans = RouteProperties(
    name: 'debtPlans',
    path: 'plans',
    pathRoot: '/debts',
  );
  static const debtLoans = RouteProperties(
    name: 'debtLoans',
    path: 'loans',
    pathRoot: '/debts',
  );
}

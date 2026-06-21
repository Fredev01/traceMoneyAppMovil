# Plan: Feature List — trace_money (Divide & Conquer)

## Context

The project is a blank Flutter app (default counter template). The architecture rules (`/.claude/rules/style-architecture.md`) and the full REST API contract (`docs/api-reference.md`) are defined, but no feature code exists yet. The goal is to identify every screen/feature the mobile client needs, map their inter-dependencies, and group them into independent development waves so multiple features can be built in parallel without blocking each other.

---

## API domains → features

| API domain | Feature name | Key responsibility |
|---|---|---|
| `GET/POST/PUT/DELETE /accounts` | **accounts** | DEBITO/CREDITO account management, capital assignment, debit transfers, movements history, account status |
| `GET/POST/PUT /expenses/categories` | **categories** | Hierarchical expense category CRUD (parent/child) |
| `GET/POST/PUT/DELETE /expenses` | **expenses** | Expense CRUD, weekly view, monthly view with filters |
| `GET/POST/PUT/DELETE /income` | **income** | Income CRUD, monthly view |
| `GET/POST/PUT /debts/cards` | **debt-cards** | Credit card registry in the debt context (independent from accounts) |
| `GET/POST/PUT/DELETE /debts/plans` | **debt-plans** | MSI installment plans, installment payment tracking |
| `GET/POST/PUT/DELETE /debts/loans` | **debt-loans** | Personal loans with CAT amortization, payment tracking |
| `GET /analytics/dashboard` | **analytics** | Monthly dashboard aggregating income, expenses, debts, accounts |

Plus one mandatory non-feature milestone:

| Milestone | Responsibility |
|---|---|
| **foundation** | pubspec.yaml packages, `core/` (DI, network, error, theme), `shared/widgets/atoms/`, go_router + main.dart |

---

## Dependency graph

```
foundation
│
├── accounts ──────────────────────────┐
├── categories ─────────────────────┐  │
├── income                           │  │
└── debt-cards ──┬── debt-plans      │  │
                 └── debt-loans      │  │
                                     ▼  ▼
                               expenses ──────┐
                                              ▼
                                         analytics
                                    (also needs: accounts,
                                     income, debt-plans,
                                     debt-loans)
```

**Dependency rationale:**
- `expenses` requires `accounts` (payment method DEBITO/CREDITO needs `account_id`) and `categories` (`category_id` is mandatory).
- `debt-plans` and `debt-loans` require `debt-cards` (both associate to a `card_id`).
- `analytics` (`GET /analytics/dashboard`) aggregates data from all other features; it can only be built last.
- `income` and `debt-cards` have zero inter-feature dependencies — purely independent leaf nodes.

---

## Divide & Conquer — development waves

### Wave 0 — Foundation *(sequential, blocks everything)*

Must be completed before any feature work starts.

**Tasks:**
1. Add all packages to `pubspec.yaml`:
   - Prod: `flutter_bloc`, `get_it`, `injectable`, `dio`, `fpdart`, `go_router`, `hive`, `hive_flutter`, `json_annotation`
   - Dev: `build_runner`, `injectable_generator`, `json_serializable`, `hive_generator`, `mocktail`, `bloc_test`
2. `lib/core/error/failure.dart` — base `Failure` sealed class
3. `lib/core/network/api_constants.dart` — base URL constant (`http://localhost:8000/api/v1`)
4. `lib/core/network/dio_client.dart` — `DioClient` singleton (`@singleton`), configured with base URL and JSON content-type
5. `lib/core/di/injection.dart` + run `build_runner` to generate `injection.config.dart`
6. `lib/core/theme/` — `AppColors`, `AppTextStyles`, `AppTheme`
7. `lib/core/constants/app_assets.dart` — asset path constants
8. `lib/shared/widgets/atoms/app_button.dart`, `app_text_field.dart`, `app_scaffold.dart`
9. `lib/app_router.dart` — go_router shell with placeholder routes
10. `lib/main.dart` — rewrite: init DI, configure router, wrap with `MultiBlocProvider` root

---

### Wave 1 — Independent leaf features *(fully parallel)*

All four can be developed simultaneously.

#### 1a · accounts
Screens: account list, create/edit account, account detail (status + movements), assign capital, transfer between debit accounts.

Layer checklist:
- domain: `Account` entity, `AccountStatus` entity, `AccountMovement` entity, `AccountFailure` sealed, `AccountRepository` abstract
- application: `GetAccountsUseCase`, `CreateAccountUseCase`, `UpdateAccountUseCase`, `DeleteAccountUseCase`, `AssignCapitalUseCase`, `TransferUseCase`, `GetAccountStatusUseCase`, `GetAccountMovementsUseCase`; DTOs: `CreateAccountDto`, `UpdateAccountDto`, `AssignCapitalDto`, `TransferDto`
- infrastructure: `AccountModel`, `AccountStatusModel`, `AccountMovementModel` (each with `toEntity()`); `AccountRemoteDataSource`; `AccountRepositoryImpl`
- presentation: `AccountCubit` (list/select) + `AccountFormBloc` (create/edit) + `AccountDetailCubit`; pages for list, form, detail

#### 1b · categories
Screens: category list (tree), create/edit category. Used as a picker inside the expense form.

Layer checklist:
- domain: `Category` entity (id, name, parentId, color), `CategoryFailure`, `CategoryRepository`
- application: `GetCategoriesUseCase`, `CreateCategoryUseCase`, `UpdateCategoryUseCase`; DTOs
- infrastructure: `CategoryModel`, `CategoryRemoteDataSource`, `CategoryRepositoryImpl`
- presentation: `CategoryCubit`; categories page + category form; `CategoryPickerWidget` (organism — used by expenses)

#### 1c · income
Screens: income list (monthly), create/edit income.

Layer checklist:
- domain: `Income` entity, `IncomeSource` enum (SUELDO/FREELANCE/BONO/INVERSION/RENTA/OTRO), `IncomeFailure`, `IncomeRepository`
- application: `GetIncomeByMonthUseCase`, `CreateIncomeUseCase`, `UpdateIncomeUseCase`, `DeleteIncomeUseCase`; DTOs
- infrastructure: `IncomeModel`, `IncomeRemoteDataSource`, `IncomeRepositoryImpl`
- presentation: `IncomeBloc` (month navigation + CRUD events); income list page, income form page

#### 1d · debt-cards
Screens: debt card list, create/edit debt card (used as a prerequisite picker in plan/loan forms).

Layer checklist:
- domain: `CreditCard` entity (debt context), `DebtCardFailure`, `DebtCardRepository`
- application: `GetDebtCardsUseCase`, `CreateDebtCardUseCase`, `UpdateDebtCardUseCase`; DTOs
- infrastructure: `CreditCardModel`, `DebtCardRemoteDataSource`, `DebtCardRepositoryImpl`
- presentation: `DebtCardCubit`; debt card list page, debt card form

---

### Wave 2 — Dependent features *(parallel with each other, needs Wave 1)*

#### 2a · expenses *(needs: accounts, categories)*
Screens: weekly expense view (with week navigation), monthly expense view (with filters), create/edit expense.

Layer checklist:
- domain: `Expense` entity, `ExpenseTag` enum (FIJO/VARIABLE/HORMIGA), `PaymentMethod` enum (EFECTIVO/DEBITO/CREDITO/TRANSFERENCIA), `ExpenseFailure`, `ExpenseRepository`
- application: `GetExpensesByWeekUseCase`, `GetExpensesByMonthUseCase`, `CreateExpenseUseCase`, `UpdateExpenseUseCase`, `DeleteExpenseUseCase`; DTOs (include `categoryId`, `accountId?`, `tag`, `paymentMethod`)
- infrastructure: `ExpenseModel`, `ExpenseRemoteDataSource`, `ExpenseRepositoryImpl`
- presentation: `ExpenseBloc` (week navigation, month navigation, CRUD); weekly page, monthly page, expense form page

**Date rule (critical):** Always derive `week_start`/`week_end` and `expense_date` from device local date — never UTC. Monday = week start.

#### 2b · debt-plans *(needs: debt-cards)*
Screens: active plans list (with installment breakdown), create plan, mark installment(s) paid, register extra payment, cancel plan.

Layer checklist:
- domain: `DebtPlan` entity, `Installment` entity (month_number, amount, due_date, status, paid_amount), `DebtPlanFailure`, `DebtPlanRepository`
- application: `GetActivePlansUseCase`, `GetMonthDebtUseCase`, `CreatePlanUseCase`, `UpdatePlanUseCase`, `CancelPlanUseCase`, `MarkInstallmentPaidUseCase`, `BulkMarkInstallmentsPaidUseCase`, `RegisterExtraPaymentUseCase`; DTOs
- infrastructure: `DebtPlanModel`, `InstallmentModel`, `DebtPlanRemoteDataSource`, `DebtPlanRepositoryImpl`
- presentation: `DebtPlanBloc`; active plans page, plan form, installment tracker widget

#### 2c · debt-loans *(needs: debt-cards)*
Screens: active loans list, create loan, view loan detail with amortization table, mark payment paid, cancel loan.

Layer checklist:
- domain: `Loan` entity, `LoanPayment` entity (cuota, interes, abono_capital, saldo_final), `LoanFailure`, `LoanRepository`
- application: `GetLoanDetailUseCase`, `GetMonthLoanUseCase`, `CreateLoanUseCase`, `UpdateLoanUseCase`, `CancelLoanUseCase`, `MarkLoanPaymentPaidUseCase`; DTOs
- infrastructure: `LoanModel`, `LoanPaymentModel`, `LoanRemoteDataSource`, `LoanRepositoryImpl`
- presentation: `LoanBloc`; loans list page, loan form, loan detail page (amortization table)

---

### Wave 3 — Analytics *(needs everything)*

#### 3 · analytics / dashboard
Single screen that aggregates: total income, total expenses, total debt payments, net balance, total active debt, category breakdown (pie/bar), tag breakdown, monthly history (sparkline), active debt cards with credit utilization, debit account balances.

Layer checklist:
- domain: `Dashboard` entity (mirrors `DashboardSummaryResponse`), `AnalyticsFailure`, `AnalyticsRepository`
- application: `GetDashboardUseCase` (year + month params)
- infrastructure: `DashboardModel`, `AnalyticsRemoteDataSource`, `AnalyticsRepositoryImpl`
- presentation: `DashboardCubit` (loads current month on init, supports month navigation); dashboard page composed of organisms (CategoryBreakdownCard, AccountStatusCard, ActiveDebtsList, MonthlyHistoryChart)

---

## Routing structure (go_router)

```
/ (shell scaffold — bottom nav)
├── /dashboard          → DashboardPage
├── /accounts
│   ├── /               → AccountsPage
│   ├── /new            → AccountFormPage
│   ├── /:id/edit       → AccountFormPage
│   └── /:id            → AccountDetailPage (status + movements)
├── /expenses
│   ├── /week           → ExpensesWeekPage
│   ├── /month          → ExpensesMonthPage
│   └── /new            → ExpenseFormPage (edit via query param)
├── /income
│   ├── /               → IncomePage
│   └── /new            → IncomeFormPage
└── /debts
    ├── /cards          → DebtCardsPage
    ├── /plans          → ActivePlansPage
    └── /loans          → LoansPage
```

---

## Enumerations (shared domain types)

Define in `lib/core/domain/` or the most-owning feature's domain:

| Enum | Values | Owner |
|---|---|---|
| `AccountType` | DEBITO, CREDITO | accounts |
| `PaymentMethod` | EFECTIVO, DEBITO, CREDITO, TRANSFERENCIA | expenses |
| `ExpenseTag` | FIJO, VARIABLE, HORMIGA | expenses |
| `IncomeSource` | SUELDO, FREELANCE, BONO, INVERSION, RENTA, OTRO | income |
| `DebtStatus` | ACTIVO, CANCELADO | debts |
| `PaymentStatus` | PENDIENTE, PAGADO | debts |
| `MovementType` | CAPITAL_INICIAL, AJUSTE_CAPITAL, TRANSFER_IN, TRANSFER_OUT | accounts |

---

## Verification checkpoints per wave

- **Wave 0:** `flutter pub get` succeeds; `flutter analyze` zero errors; DI module generates without conflict; app launches with router shell on a device/emulator.
- **Wave 1:** Each feature can be navigated to independently; create/list/edit/delete flows complete against the live backend (`http://localhost:8000`); `flutter test` passes for each new use case.
- **Wave 2:** Expense form correctly populates account picker and category picker from Wave 1 data; debt plan form requires a debt card; installment list reflects API state.
- **Wave 3:** Dashboard page loads in a single request; all sections display non-null data; month navigation re-fetches.

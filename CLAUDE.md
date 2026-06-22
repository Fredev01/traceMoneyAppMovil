# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**trace_money** is a personal finance Flutter app (MXN currency, single-user) that consumes a local REST API at `http://localhost:8000/api/v1`. The full API contract is in `docs/api-reference.md`. The feature development plan is in `docs/plans/feature-list-divide-and-conquer.md`.

> **Architecture rules and best practices are defined in `.claude/rules/style-architecture.md`.**  
> That file is the single source of truth for layer structure, BLoC vs Cubit criteria, state design, dependency wiring, shared widgets, and file naming conventions. When in doubt, consult it first.

---

## Commands

```bash
flutter pub get       # Install dependencies
flutter run           # Run the app
flutter analyze       # Lint
flutter test          # All tests
flutter test test/features/accounts/...  # Single feature
```

---

## Stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` (BLoC / Cubit) |
| State equality | `equatable` |
| HTTP | `dio` |
| Error handling | `fpdart` (`Either<Failure, T>`) |
| Routing | `go_router` |
| Local storage | `hive` + `hive_flutter`, `flutter_secure_storage` |
| Serialization | Manual `fromJson` — no codegen (`build_runner`/`json_serializable` not used) |
| Testing | `mocktail` + `bloc_test` |

**No DI framework.** Repositories are provided via `RepositoryProvider` in `main.dart`. Use cases are instantiated inline inside `BlocProvider` with `ctx.read<XRepository>()`. See `style-architecture.md` → *Dependency wiring*.

---

## Architecture

Four-layer feature structure — full rules in `style-architecture.md`:

```
features/<feature_name>/
├── domain/          # Pure Dart — entities, repo interfaces, failures
├── application/     # Use cases, DTOs — no BLoC, no Dio
├── infrastructure/  # Dio datasources, models with toEntity(), repo impls
└── presentation/    # BLoC/Cubit, pages, feature widgets
```

Core:
```
lib/
├── core/
│   ├── error/       # abstract class Failure (base)
│   ├── network/     # DioClient (factory singleton), ApiConstants, response/
│   ├── router/      # RouteProperties
│   ├── theme/       # AppTheme, AppColors, AppTextStyles
│   └── utils/       # AppAssets
├── router/
│   ├── app_router.dart   # GoRouter + ShellRoute + BlocProvider per route
│   └── routes.dart       # Typed route catalog
├── shared/widgets/
│   ├── atoms/       # AppButton, AppTextField, AppScaffold
│   ├── molecules/
│   └── organisms/   # AppShell (bottom nav)
└── main.dart        # MultiRepositoryProvider root
```

---

## Key rules (summary — full detail in `style-architecture.md`)

**Routing:** Never write raw path strings. Always use `Routes.<name>`. BLoC is provided in `app_router.dart`, never inside the page.

**Initial load:** Never chain `..method()` in `create:`. Dispatch the first event/call in `initState`.

```dart
// ❌ Wrong
create: (_) => AccountsCubit(useCase)..loadAccounts(),

// ✅ Correct — dispatch in initState
create: (ctx) => AccountsCubit(GetAccountsUseCase(ctx.read<AccountRepository>())),
```

**Presentation:** States and events use `sealed class` + `Equatable`. Never use `ElevatedButton`, `TextFormField`, or `Scaffold` directly — use `AppButton`, `AppTextField`, `AppScaffold`.

**Error handling:** `try/catch` only in infrastructure datasources. BLoC maps `Left(failure)` → error state.

**Assets:** Only via `AppAssets.constantName`. No hardcoded paths in widgets.

---

## API notes

- Base URL: `http://localhost:8000/api/v1` — no auth required
- Amounts: decimal strings (`"1500.00"`)
- Dates: `YYYY-MM-DD` from **device local date** — never UTC/ISO conversion
- Error envelope: `{ "detail": { "code": "...", "message": "..." } }`
- `201` → `{ "id": "uuid" }`, `204` → no body

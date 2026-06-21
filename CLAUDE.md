# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**trace_money** is a personal finance Flutter app (MXN currency, single-user) that consumes a local REST API at `http://localhost:8000/api/v1`. The full API contract is in `docs/api-reference.md`. The feature development plan is in `docs/plans/feature-list-divide-and-conquer.md`.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Analyze (lint)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/features/accounts/...
```

**When adding the first Hive model or JSON model (Wave 1+)**, uncomment these in `pubspec.yaml` dev_dependencies and run:
```bash
# build_runner: ^2.4.13
# hive_generator: ^2.0.1
# json_serializable: ^6.8.0
dart run build_runner build
```

## Stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` (BLoC / Cubit) |
| HTTP | `dio` |
| Error handling | `fpdart` (`Either<Failure, T>`) |
| Routing | `go_router` |
| Local storage | `hive` + `hive_flutter`, `flutter_secure_storage` |
| Serialization | `json_annotation` (codegen added in Wave 1) |
| Testing | `mocktail` + `bloc_test` |

**No DI framework.** Dependencies are wired via manual constructor injection. `DioClient` is a Dart factory singleton — call `DioClient()` anywhere to get the shared instance.

## Architecture

Every feature lives under `lib/features/<feature_name>/` in four layers:

```
features/<feature_name>/
├── domain/          # Pure Dart — entities, value objects, repo interfaces, failures
├── application/     # Use cases, DTOs, mappers — no BLoC, no Dio
├── infrastructure/  # Dio datasources, Hive models, repo implementations
└── presentation/    # BLoC/Cubit, pages, feature-specific widgets
```

Core and shared:
```
lib/
├── core/
│   ├── error/       # Base Failure sealed class
│   ├── network/     # DioClient (factory singleton), ApiConstants
│   ├── router/      # RouteProperties class
│   ├── theme/       # AppTheme, AppColors, AppTextStyles
│   └── utils/       # AppAssets
├── router/
│   ├── app_router.dart   # GoRouter instance with ShellRoute + errorBuilder
│   └── routes.dart       # Typed route catalog (Routes.dashboard, Routes.accounts, …)
├── shared/widgets/
│   ├── atoms/       # AppButton, AppTextField, AppScaffold
│   ├── molecules/
│   └── organisms/   # AppShell (bottom nav wrapper)
└── main.dart
```

## Routing

**Never write raw path strings.** Every navigation call uses `Routes.<name>`:

```dart
context.goNamed(Routes.accounts.name);
context.goNamed(Routes.accountDetail.name, pathParameters: {'accountId': id});
```

`Routes` is in `lib/router/routes.dart` — add a new `RouteProperties` constant there for every new route, then wire it in `lib/router/app_router.dart`.

`RouteProperties` (`lib/core/router/route_properties.dart`) exposes:
- `name` — used with `goNamed()`
- `path` — URL fragment (may be relative for nested routes)
- `pathRoot` — optional parent path for documentation
- `fullPath` — `pathRoot/path`, used in router redirects

BLoC is always provided in `app_router.dart`, never inside the Page itself.

## Key layer constraints

**Domain:** Zero Flutter or external-package imports. No `fromJson`/`toJson` on entities. Failures are sealed classes.

**Application:** Use cases return `Future<Either<Failure, T>>`. Accept DTOs, not raw primitives. No BLoC, no Dio.

**Infrastructure:** Only layer that may import Dio, Hive, or `json_serializable`. JSON models live here and each has a `toEntity()` method. Never `fromModel()` on entities.

**Presentation:** `sealed class` for both events and states. Never use `ElevatedButton`, `TextFormField`, or `Scaffold` directly — use `AppButton`, `AppTextField`, `AppScaffold` from `shared/widgets/atoms/`. Only pages and organisms may contain `BlocBuilder`/`BlocListener`.

**Error handling:** `try/catch` only in infrastructure datasources. BLoC maps `Left(failure)` to an error state; never rethrows.

**Assets:** Reference via `AppAssets.constantName` (`lib/core/utils/app_assets.dart`). No hardcoded path strings in widgets.

## API notes

- Base URL: `http://localhost:8000/api/v1` — no auth required
- Amounts: decimal strings (`"1500.00"`)
- Dates: `YYYY-MM-DD` from **device local date** — never UTC/ISO conversion
- Error envelope: `{ "detail": { "code": "...", "message": "..." } }`
- `201` → `{ "id": "uuid" }`, `204` → no body

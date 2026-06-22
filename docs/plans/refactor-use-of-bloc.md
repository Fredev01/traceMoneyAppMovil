# Refactor Prompt — Flutter BLoC Wiring & Lifecycle

## Context

This is an existing Flutter project using `flutter_bloc`, `go_router`, and a four-layer architecture (`domain`, `application`, `infrastructure`, `presentation`). The current `app_router.dart` declares all dependencies (Dio, repositories, datasources, use cases) as **top-level globals at file scope**. This must be refactored to follow the rules in `CLAUDE.md`.

The architectural rules to enforce are defined in `CLAUDE.md` at the project root. Read that file first and treat it as the source of truth. This prompt only describes the refactor; the rules live in `CLAUDE.md`.

## Goal

Eliminate global instances from `app_router.dart`, move repository wiring to `main.dart` via `RepositoryProvider`, and clean up BLoC lifecycle anti-patterns.

## Scope

Files to modify:

- `lib/main.dart`
- `lib/router/app_router.dart`
- All page files under `lib/features/*/presentation/pages/` that currently rely on `..loadX()` chained inside `create:`.
- All state classes under `lib/features/*/presentation/bloc/` that do not implement `Equatable`.

Files to **not** touch unless explicitly required:

- `domain/`, `application/`, `infrastructure/` layers.
- Route catalog (`lib/router/routes.dart`).

## Required changes

### 1. Move repository wiring to `main.dart`

Wrap the app in `MultiRepositoryProvider`. Each repository is instantiated once and provided via context. `DioClient` is instantiated once at the top of `main()` and injected into each datasource.

```dart
void main() {
  final dio = DioClient();
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AccountRepository>(
          create: (_) => AccountRepositoryImpl(AccountRemoteDataSource(dio)),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (_) => CategoryRepositoryImpl(CategoryRemoteDataSource(dio)),
        ),
        // one per feature
      ],
      child: const App(),
    ),
  );
}
```

### 2. Remove all globals from `app_router.dart`

Delete every top-level `final _xxx = ...` declaration. Use cases are now created inline inside each `BlocProvider.create:` using `context.read<XRepository>()`:

```dart
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
),
```

### 3. Move initial events from `create:` to `initState`

Any line matching `..loadX()` or `..add(XStarted())` chained after `BlocProvider.create:` must be removed and re-dispatched inside the page's `initState`. Pages that are currently `StatelessWidget` must be promoted to `StatefulWidget` only if they need this hook.

```dart
// In app_router.dart — BEFORE
create: (_) => AccountsCubit(_getAccounts)..loadAccounts(),

// In app_router.dart — AFTER
create: (ctx) => AccountsCubit(GetAccountsUseCase(ctx.read<AccountRepository>())),

// In accounts_page.dart — ADD
@override
void initState() {
  super.initState();
  context.read<AccountsCubit>().loadAccounts();
}
```

### 4. Ensure all states implement `Equatable`

For every `sealed class XState` and its subclasses, extend `Equatable` and override `props`. Same for events. If `equatable` is not in `pubspec.yaml`, add it.

### 5. Split BLoCs with too many responsibilities

If any BLoC receives 5+ use cases in its constructor, or mixes list/read concerns with form/write concerns, split it:

- `XListCubit` — read-only listing.
- `XFormBloc` — create/update/delete.

Each gets its own folder under `presentation/bloc/`.

## Constraints

- Do not introduce `get_it`, `injectable`, or any DI framework.
- Do not add `build_runner` dependencies beyond `json_serializable` if it already exists.
- Do not modify domain entities, use cases, or repository interfaces.
- Do not change route paths or names in `routes.dart`.
- Preserve all existing functionality. This is a structural refactor only.

## Verification steps

After the refactor, confirm by running:

1. `flutter analyze` — must pass with zero warnings.
2. `flutter test` — all existing tests must still pass.
3. Manual grep: `grep -n "^final _" lib/router/app_router.dart` must return zero results.
4. Manual grep: `grep -rn "\.\.load\|\.\.add(" lib/router/` must return zero results.
5. Manual grep: `grep -rn "class.*State extends" lib/features/ | grep -v Equatable` should ideally return zero results (every state class extends Equatable transitively).

## Deliverable

For each modified file, produce:

- The full new content of the file.
- A short summary (3-5 bullets) of what changed and why.

Do not produce partial diffs. Produce complete files ready to replace the originals.

## Order of execution

1. Read `CLAUDE.md` at the project root.
2. Inventory all globals in `app_router.dart` and group them by feature.
3. Refactor `main.dart` with `MultiRepositoryProvider`.
4. Refactor `app_router.dart` removing globals and chained events.
5. Update each affected page to dispatch initial events in `initState`.
6. Add `Equatable` to all states and events that lack it.
7. Run verification steps and report results.

Work feature by feature. Do not attempt the whole app in one pass.

# Flutter Architecture Rules

## Stack

- **Language:** Dart (Flutter)
- **State management:** flutter_bloc (BLoC / Cubit)
- **HTTP:** Dio
- **Serialization:** json_serializable
- **Error handling:** fpdart (`Either<Failure, T>`)
- **Routing:** go_router
- **Local storage:** flutter_secure_storage (tokens), Hive (datos locales)
- **Testing:** mocktail + bloc_test

---

## Layer structure

Every feature follows this exact four-layer structure:

```
features/<feature_name>/
├── domain/
├── application/
├── infrastructure/
└── presentation/
```

---

## Domain

**Rule:** Pure Dart only. Zero Flutter imports. Zero external package imports.

Contains:

- `entities/` — Aggregate roots and plain data classes. No JSON logic.
- `value_objects/` — Immutable wrappers with built-in validation. Validation returns `Either<Failure, ValueObject>`, never throws.
- `repositories/` — Abstract interfaces only (`abstract class`). No implementation here.
- `failures/` — Sealed classes extending a base `Failure`. One file per feature.

Forbidden:

- No `fromJson` / `toJson` in entities.
- No references to `infrastructure/` or `presentation/`.
- No Flutter imports (`package:flutter/...`).

---

## Application

**Rule:** Orchestrates domain. No business logic of its own.

Contains:

- `use_cases/` — One class per action. One public method: `call()`. Always returns `Future<Either<Failure, T>>`.
- `dtos/` — Input/output objects for use cases (`LoginRequestDto`, `UserResponseDto`). Not domain entities.
- `mappers/` — Conversion between DTOs and domain entities.

Rules:

- Use cases receive DTOs, not raw primitives or entities.
- Use cases call repository interfaces from `domain/`, never `infrastructure/` directly.
- No BLoC, no widgets, no Dio here.

```dart
class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<Either<AuthFailure, User>> call(LoginRequestDto dto) {
    return _repository.login(email: dto.email, password: dto.password);
  }
}
```

---

## Infrastructure

**Rule:** The only layer allowed to know about external packages (Dio, Hive, json_serializable).

Contains:

- `repositories/` — Concrete implementations of domain abstract classes.
- `datasources/remote/` — Dio calls to the REST API. One class per feature.
- `datasources/local/` — Hive / flutter_secure_storage reads and writes.
- `models/` — JSON-serializable classes (`@JsonSerializable`). Each model has a `toEntity()` method. Entities never have `fromModel()`.

Rules:

- `RepositoryImpl` decides whether to call remote or local datasource.
- Models belong here. Entities belong in `domain/`.
- JWT token injection is handled exclusively in `AuthInterceptor` inside `core/network/`.

```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<AuthFailure, User>> login({...}) async { ... }
}
```

---

## Presentation

**Rule:** BLoC orchestrates, widgets display. No business logic in either.

Contains:

- `bloc/` — `*Bloc` or `*Cubit`, `*Event` (sealed), `*State` (sealed).
- `pages/` — Full screens. Provides BLoC via `BlocProvider`. Uses `BlocBuilder` / `BlocListener`.
- `widgets/` — Feature-specific widgets. No BLoC access; receive data via constructor.

Rules:

- BLoC imports use cases from `application/` only. Never repositories.
- Use `sealed class` for both events and states (Dart 3+).
- Use BLoC when there are multiple distinct events. Use Cubit for simple read-only screens.
- Widgets never import repositories or use cases directly.

```dart
sealed class AuthEvent { const AuthEvent(); }
class LoginRequested extends AuthEvent {
  final LoginRequestDto dto;
  const LoginRequested(this.dto);
}

sealed class AuthState { const AuthState(); }
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);
}
class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);
}
```

---

## Routing

```
lib/
└── router/
    ├── app_router.dart
    └── routes.dart
```

This folder lives at the same level as `main.dart`.

### app_router.dart

Core of the app's navigation. Uses `go_router` to define a declarative routing system. Resolves five architectural needs:

1. **Route tree** — Nested routes and sub-routes hierarchy.
2. **Route protection** — Redirect middleware for private routes (checks auth state).
3. **Nested navigation** — `ShellRoute` for persistent UI (bottom nav, side drawer).
4. **External auth flow** — OAuth deep link handling.
5. **Error and initial state handling** — `errorBuilder` and `initialLocation`.

```dart
final appRouter = GoRouter(
  initialLocation: Routes.home.path,
  redirect: (context, state) {
    final isAuthenticated = ...; // read auth state
    final isGoingToLogin = state.matchedLocation == Routes.login.path;
    if (!isAuthenticated && !isGoingToLogin) return Routes.login.path;
    if (isAuthenticated && isGoingToLogin) return Routes.home.path;
    return null;
  },
  routes: [ ... ],
  errorBuilder: (context, state) => ErrorPage(error: state.error),
);
```

### routes.dart

Centralized catalog of all app routes. Never write raw path strings (`"/login"`, `"/home"`) anywhere in the codebase — always reference `Routes.<name>`.

Serves three purposes:

1. **Strong typing** — Prevents typos in paths across the codebase.
2. **Centralized maintenance** — Changing a path requires editing one place only.
3. **Separation of concerns** — Navigation intent is decoupled from path implementation.

```dart
class Routes {
  static final login = RouteProperties(
    name: 'login',
    path: '/login',
  );

  static final home = RouteProperties(
    name: 'home',
    path: '/home',
  );

  static final meterDetail = RouteProperties(
    name: 'meterDetail',
    path: 'detail/:idMeter',
    pathRoot: '/meter',
  );
}
```

Navigate always by name:

```dart
context.goNamed(Routes.login.name);
context.goNamed(Routes.meterDetail.name, pathParameters: {'idMeter': id});
```

### RouteProperties

Defined in `core/router/route_properties.dart`:

```dart
class RouteProperties {
  final String name;
  final String path;
  final String? pathRoot;

  RouteProperties({
    required this.name,
    required this.path,
    this.pathRoot,
  });
}
```

- `name` — Unique identifier. Used with `context.goNamed()`.
- `path` — URL fragment. May contain dynamic parameters (`:idMeter`).
- `pathRoot` — Optional. Documents the absolute parent path for nested routes.

---

## Shared widgets — Atomic Design

```
shared/widgets/
├── atoms/       # AppButton, AppTextField, AppChip — no domain knowledge
├── molecules/   # LabeledField, SearchBar — compose atoms
└── organisms/   # AppNavBar, ExpenseList — may receive domain data, no BLoC
```

Rules:

- Atoms have zero domain knowledge.
- Only pages and organisms may contain `BlocBuilder` / `BlocListener`.
- Molecules and atoms receive everything via constructor parameters.

### Available shared widgets

Before creating a new widget, check `shared/widgets/` first:

- `AppButton` — primary/secondary button with loading state.
- `AppTextField` — text field with integrated validation.
- `AppScaffold` — base scaffold with AppBar configured.

Never use `ElevatedButton`, `TextFormField`, or `Scaffold` directly in pages or features. Always use the wrappers from `shared/widgets/atoms/`.

---

## Core

```
core/
├── error/        # base Failure sealed class, base Exception
├── network/      # DioClient, AuthInterceptor (JWT + refresh)
├── router/       # RouteProperties class
├── theme/        # AppTheme, AppColors, AppTextStyles
└── utils/        # Either extensions, constants, AppAssets
```

---

## Assets

Image and icon paths only via `AppAssets.iconName` (`lib/core/utils/app_assets.dart`).
Never hardcode asset path strings inside widgets.

---

## Dependency rules (enforced in every PR)

| From ↓ \ To →      | domain | application | infrastructure | presentation |
| ------------------ | ------ | ----------- | -------------- | ------------ |
| **domain**         | ✅     | ❌          | ❌             | ❌           |
| **application**    | ✅     | ✅          | ❌             | ❌           |
| **infrastructure** | ✅     | ✅          | ✅             | ❌           |
| **presentation**   | ✅     | ✅          | ❌             | ✅           |

Infrastructure implements domain interfaces (dependency inversion). It never imports presentation.

---

## Error handling

- All repository interfaces and use cases return `Either<Failure, T>`.
- No raw `try/catch` exposed in BLoC or use cases — wrap in infrastructure datasources only.
- `Failure` is a sealed class defined in `domain/failures/`.
- BLoC maps `Left(failure)` to an error state. Never rethrows.

---

## File naming

| Type                 | Convention                   | Example                     |
| -------------------- | ---------------------------- | --------------------------- |
| Entity               | `snake_case.dart`            | `user.dart`                 |
| Use case             | `verb_noun_use_case.dart`    | `login_use_case.dart`       |
| Repository interface | `noun_repository.dart`       | `auth_repository.dart`      |
| Repository impl      | `noun_repository_impl.dart`  | `auth_repository_impl.dart` |
| Model (DTO infra)    | `noun_model.dart`            | `user_model.dart`           |
| BLoC                 | `noun_bloc/event/state.dart` | `auth_bloc.dart`            |
| Page                 | `noun_page.dart`             | `login_page.dart`           |
| Router               | `app_router.dart`            | `app_router.dart`           |
| Routes catalog       | `routes.dart`                | `routes.dart`               |

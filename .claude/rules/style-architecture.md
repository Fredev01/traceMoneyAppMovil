# Flutter Architecture Rules

## Stack

- **Language:** Dart (Flutter)
- **State management:** flutter_bloc (BLoC / Cubit)
- **DI:** get_it + injectable
- **HTTP:** Dio
- **Serialization:** json_serializable
- **Error handling:** fpdart (`Either<Failure, T>`)
- **Routing:** go_router
- **Local storage:** Hive
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
@injectable
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

- `repositories/` — Concrete implementations of domain abstract classes. Annotated with `@Injectable(as: XRepository)`.
- `datasources/remote/` — Dio calls to the REST API. One class per feature.
- `datasources/local/` — Hive / SQLite reads and writes.
- `models/` — JSON-serializable classes (`@JsonSerializable`). Each model has a `toEntity()` method. Entities never have `fromModel()`.

Rules:

- `RepositoryImpl` decides whether to call remote or local datasource.
- Models belong here. Entities belong in `domain/`.
- JWT token injection is handled exclusively in `AuthInterceptor` inside `core/network/`.

```dart
@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

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

---

## Shared widgets disponibles

Antes de crear un widget nuevo, verificar si existe en `shared/widgets/`:

- `AppButton` — botón primario/secundario con loading state
- `AppTextField` — campo con validación integrada
- `AppScaffold` — scaffold base con AppBar configurado

## Widgets

- Nunca usar `ElevatedButton`, `TextFormField` o `Scaffold` directamente en pages o features.
- Siempre usar los wrappers de `shared/widgets/atoms/`.

## Provisión de BLoC

El BLoC se provee siempre en el router (GoRouter), nunca dentro de la Page misma.

## Assets

Rutas de imágenes y íconos solo via `AppAssets.iconName` (lib/core/constants/app_assets.dart).
Nunca strings hardcodeados de rutas en widgets.

## Core

```
core/
├── di/           # injection.dart + injection.config.dart (generated)
├── error/        # base Failure sealed class, base Exception
├── network/      # DioClient, AuthInterceptor (JWT + refresh)
├── theme/        # AppTheme, AppColors, AppTextStyles
└── utils/        # Either extensions, constants
```

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

## DI registration

- Use `@injectable` on use cases and datasources.
- Use `@Injectable(as: XRepository)` on repository implementations.
- Use `@singleton` on `DioClient` and `AuthInterceptor`.
- Run `flutter pub run build_runner build --delete-conflicting-outputs` after any DI change.

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

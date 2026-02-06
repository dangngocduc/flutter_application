# GitHub Copilot Instructions - Flutter Application

## Project Overview

This is a production Flutter mobile application built with Clean Architecture principles, featuring modern state management and robust API integration patterns. The project targets Flutter 3.x+ with Dart 3.5+ SDK and is designed for scalability, maintainability, and team collaboration.

### Architecture

**Clean Architecture with 3 Layers:**

1. **Domain Layer** (`lib/domain/`)
   - Business logic and entity definitions
   - Repository interfaces (contracts)
   - Use cases for business operations
   - Technology-agnostic, pure Dart code

2. **Data Layer** (`lib/data/`)
   - Implementation of domain repositories
   - Data sources (remote API, local storage)
   - DTOs (Data Transfer Objects) with JSON serialization
   - API service clients using Dio + Retrofit patterns

3. **Presentation Layer** (`lib/ui/`)
   - UI components (pages, widgets)
   - State management with BLoC pattern (flutter_bloc)
   - Navigation and routing
   - User interaction handling

### Technology Stack

**Core Dependencies:**
- **Flutter SDK**: 3.5.0+ (target latest stable)
- **Dart SDK**: 3.5.0+
- **State Management**: `flutter_bloc` (BLoC pattern)
- **Dependency Injection**: `get_it` (service locator)
- **HTTP Client**: `dio` with `oauth2_dio` for authentication
- **Serialization**: `json_serializable`, `freezed` for immutable state/models
- **Local Storage**: `shared_preferences`
- **Navigation**: `auth_nav` (custom auth-aware navigation)
- **Internationalization**: `flutter_intl`, `flutter_localizations`

**Dev Dependencies:**
- `build_runner` - Code generation
- `freezed` - Code generation for unions/sealed classes
- `json_serializable` - JSON serialization code generation
- `flutter_lints` - Dart linting rules
- `flutter_launcher_icons` - App icon generation
- `flutter_native_splash` - Splash screen generation

### Directory Structure

```
lib/
├── core/               # (Future) Core utilities, constants, base classes
├── data/               # Data Layer
│   ├── datasource/
│   │   ├── local/      # Local data sources (SharedPreferences, etc.)
│   │   └── remote/     # Remote API services
│   ├── dto/            # Data Transfer Objects (DTOs)
│   └── repositories/   # Repository implementations
├── domain/             # Domain Layer
│   ├── entity/         # Business entities/models
│   ├── repository/     # Repository interfaces
│   └── usecase/        # Business use cases
├── presentation/       # (Alternative name for ui/)
├── ui/                 # Presentation Layer
│   ├── blocs/          # BLoC state management
│   ├── pages/          # Full screen pages
│   └── widgets/        # Reusable UI components
├── utils/              # Utility functions and extensions
├── gen/                # Generated code (assets)
├── generated/          # Generated code (intl)
├── l10n/               # Localization files
├── application.dart    # MaterialApp configuration
├── initialize_dependencies.dart  # DI setup
├── main.dart           # App entry point
└── themes.dart         # Theme configuration
```

### Naming Conventions

**Files:**
- Use `snake_case` for all Dart files: `auth_repository.dart`, `sign_in_page.dart`
- DTOs: `*_dto.dart` (e.g., `authentication_dto.dart`, `profile_dto.dart`)
- Pages: `*_page.dart` (e.g., `sign_in_page.dart`, `home_page.dart`)
- Widgets: `*_widget.dart` (e.g., `custom_button_widget.dart`)
- BLoCs: `*_bloc.dart`, `*_state.dart`, `*_event.dart`
- Repositories (implementation): `*_repository.dart`
- API Services: `*_api_service.dart`
- Use cases: `*_usecase.dart` or `*_use_case.dart`

**Classes:**
- Use `PascalCase` for class names
- DTOs: `*Dto` suffix (e.g., `AuthenticationDto`, `ProfileDto`)
- Pages: `*Page` suffix (e.g., `SignInPage`, `HomePage`)
- Widgets: `*Widget` suffix for custom widgets
- BLoCs: `*Bloc` suffix (e.g., `AuthBloc`)
- State classes: `*State` suffix (e.g., `AuthState`)
- Events: `*Event` suffix
- Repositories: `*Repository` suffix
- Use cases: `*UseCase` suffix

**Variables:**
- Use `camelCase` for variables and parameters
- Private members: prefix with underscore `_privateField`
- Constants: use `lowerCamelCase` or `SCREAMING_SNAKE_CASE` for compile-time constants

**Assets:**
- Icons: `ic_*` prefix (e.g., `ic_home.svg`, `ic_profile.png`)
- Images: `image_*` or `img_*` prefix (e.g., `image_logo.png`)

### Code Generation Commands

**Generate code for Freezed and JSON Serializable:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
# Or use the provided script:
bash gen.sh
```

**Generate assets (using flutter_gen):**
```bash
fluttergen -c pubspec.yaml
# Or use the provided script:
bash gen_quick_import.sh
```

**Generate app icons:**
```bash
flutter pub run flutter_launcher_icons:main
```

**Generate splash screen:**
```bash
flutter pub run flutter_native_splash:create --path=flutter_native_splash.yaml
```

### Development Workflow

**Running the app:**
```bash
# Development flavor
flutter run --flavor development --dart-define=FLAVOR=development

# Production flavor
flutter run --flavor production --dart-define=FLAVOR=production
```

**Building for release:**
```bash
# Android APK
flutter build apk --flavor production --dart-define=FLAVOR=production

# iOS
flutter build ios --flavor production --dart-define=FLAVOR=production
```

**Testing:**
```bash
flutter test
```

**Linting:**
```bash
flutter analyze
```

### Dependency Injection Setup

All global dependencies are initialized in `initialize_dependencies.dart` using `get_it`:
- Repositories
- BLoCs
- Services (local storage, API clients)
- Use cases

Example:
```dart
final getIt = GetIt.instance;

void initializeDependencies() {
  // Services
  getIt.registerLazySingleton<AuthApiService>(() => AuthApiService());
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  
  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc());
}
```

### State Management Patterns

This project uses **BLoC pattern** (flutter_bloc):
- Events represent user interactions or system events
- States represent UI states (loading, success, error, etc.)
- BLoCs handle business logic and state transitions
- Use `freezed` for immutable state classes with union types

**Example BLoC structure:**
```dart
// State
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.authorized(ProfileDto profile) = AuthStateAuthorized;
  const factory AuthState.unAuthorized() = AuthStateUnAuthorized;
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Implementation
}
```

### API Integration

- Use `dio` for HTTP requests
- Authentication via `oauth2_dio` (OAuth2 token management)
- API services in `lib/data/datasource/remote/`
- DTOs for request/response models with `json_serializable`

### Localization

- Use `flutter_intl` for internationalization
- ARB files in `lib/l10n/`
- Generated localization code in `lib/generated/intl/`
- Access translations via `S.of(context).translationKey`

### Best Practices for GitHub Copilot

**When writing code:**
1. **Provide clear context**: Include imports and class names in prompts
2. **Use type annotations**: Help Copilot understand data flow
3. **Follow established patterns**: Reference existing files for consistency
4. **Leverage freezed**: Use for immutable models and union types
5. **Use extensions**: Leverage existing extensions in `lib/utils/`

**When generating models/DTOs:**
- Always include `@JsonSerializable()` annotation
- Add `part` directive for generated file
- Implement `fromJson` and `toJson` factory methods
- Use `freezed` for domain models and state classes

**When creating BLoCs:**
- Use `freezed` for state classes with union types
- Separate events, states, and bloc into different files (or use union pattern)
- Handle all event cases
- Use repositories for data access, never call services directly

**When building UI:**
- Prefer `StatelessWidget` for stateless UI
- Use BLoC for state management, not `StatefulWidget` with manual state
- Extract reusable components into separate widget files
- Use extensions from `lib/utils/` for `BuildContext` and `State`

**When working with async operations:**
- Always handle errors
- Show loading states
- Use `Future` and `async/await` patterns
- Consider using `stream_transform` for complex stream operations

### Common Pitfalls to Avoid

1. **Don't mix layers**: Keep domain, data, and presentation separate
2. **Don't use DTOs in UI**: Convert DTOs to domain entities
3. **Don't bypass BLoC**: All state changes should go through BLoC
4. **Don't forget to generate code**: Run `build_runner` after changing models
5. **Don't hardcode strings**: Use localization for all user-facing text
6. **Don't store sensitive data insecurely**: Use secure storage for tokens/credentials

### Quick Reference

**File patterns to recognize:**
- `*.freezed.dart` - Generated by Freezed (immutable classes)
- `*.g.dart` - Generated by json_serializable or build_runner
- `*.gen.dart` - Generated asset references

**Import barrel files:**
- `lib/data/dto/dto.dart` - All DTOs
- `lib/ui/blocs/blocs.dart` - All BLoCs
- `lib/ui/pages/pages.dart` - All pages
- `lib/domain/entity/entity.dart` - All entities

### Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Library](https://bloclibrary.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Dio HTTP Client](https://pub.dev/packages/dio)

### Module-Specific Instructions

For detailed instructions on specific modules, see:
- `.github/instructions/models.instructions.md` - Models, DTOs, and Freezed patterns
- `.github/instructions/widgets.instructions.md` - UI components and widget patterns
- `.github/instructions/services.instructions.md` - API services and repositories
- `.github/instructions/tests.instructions.md` - Testing patterns and templates

### Copilot CLI Usage

Use GitHub Copilot CLI for common tasks:

```bash
# Explain code
gh copilot explain "What does this BLoC do?"

# Suggest commands
gh copilot suggest "How to build a release APK with production flavor"

# Generate code
gh copilot suggest "Create a new BLoC for user profile management"
```

---

**Last Updated**: 2026-02-06  
**Flutter Version**: 3.5.0+  
**Dart Version**: 3.5.0+

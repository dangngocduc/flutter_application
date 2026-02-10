# GitHub Copilot Agents - Developer Onboarding

## Welcome, Copilot Agent! 👋

This document contains essential information for GitHub Copilot Agents working on this Flutter mobile application. Please read carefully before making any changes to ensure consistency, quality, and adherence to project standards.

## Project Quick Facts

- **Type**: Flutter mobile application
- **Architecture**: Clean Architecture (3 layers: Domain, Data, Presentation)
- **State Management**: BLoC pattern (flutter_bloc)
- **Dependency Injection**: GetIt (service locator)
- **HTTP Client**: Dio with oauth2_dio for authentication
- **Code Generation**: freezed, json_serializable, build_runner
- **Minimum SDK**: Dart 3.5.0+, Flutter 3.5.0+
- **Target Platforms**: iOS, Android, Web (primary focus: mobile)

## Critical Rules - Read First! ⚠️

### 1. Architecture Boundaries
- **NEVER** mix layers inappropriately:
  - Domain layer: Pure Dart, no external dependencies
  - Data layer: DTOs with JSON annotations, implements domain interfaces
  - Presentation layer: UI and BLoC only
- **NEVER** use DTOs directly in UI - always map to domain entities first
- **NEVER** call API services directly from BLoC - always use repositories

### 2. State Management
- **ALWAYS** use BLoC pattern for state management
- **NEVER** use StatefulWidget for business logic state
- **ALWAYS** use freezed for state classes with union types
- **ALWAYS** dispatch events to BLoC, never manipulate state directly

### 3. Code Generation
- **ALWAYS** run `flutter pub run build_runner build --delete-conflicting-outputs` after:
  - Creating/modifying DTOs with `@JsonSerializable()`
  - Creating/modifying state classes with `@freezed`
  - Adding any code that requires generation
- **NEVER** manually edit `.g.dart` or `.freezed.dart` files

### 4. Naming Conventions
- Files: `snake_case` (e.g., `user_repository.dart`)
- Classes: `PascalCase` (e.g., `UserRepository`)
- DTOs: `*Dto` suffix (e.g., `UserDto`)
- Pages: `*Page` suffix (e.g., `SignInPage`)
- BLoCs: `*Bloc` suffix (e.g., `AuthBloc`)
- Assets icons: `ic_*` prefix
- Assets images: `image_*` or `img_*` prefix

### 5. Dependencies
- **ALWAYS** add new dependencies to `pubspec.yaml`
- **ALWAYS** run `flutter pub get` after modifying dependencies
- **PREFER** well-maintained, popular packages
- **CHECK** package compatibility with Flutter 3.5.0+

### 6. Testing
- **ALWAYS** write tests for new business logic
- **ALWAYS** use AAA pattern (Arrange-Act-Assert)
- **ALWAYS** mock external dependencies
- **NEVER** commit code that breaks existing tests

## Directory Structure Reference

```
lib/
├── data/                       # Data Layer
│   ├── datasource/
│   │   ├── local/              # SharedPreferences, etc.
│   │   └── remote/             # API services
│   ├── dto/                    # Data Transfer Objects (JSON models)
│   └── repositories/           # Repository implementations
├── domain/                     # Domain Layer
│   ├── entity/                 # Business entities
│   ├── repository/             # Repository interfaces
│   └── usecase/                # Business use cases
├── ui/                         # Presentation Layer
│   ├── blocs/                  # BLoC state management
│   ├── pages/                  # Full-screen pages
│   └── widgets/                # Reusable components
├── utils/                      # Utilities and extensions
├── gen/                        # Generated assets code
├── generated/                  # Generated intl code
├── application.dart            # MaterialApp configuration
├── initialize_dependencies.dart # Dependency injection setup
└── main.dart                   # Entry point
```

## Common Tasks Quick Guide

### Task 1: Create a New Model

1. **Create DTO** in `lib/data/dto/`:
   ```dart
   import 'package:json_annotation/json_annotation.dart';
   part 'product_dto.g.dart';
   
   @JsonSerializable()
   class ProductDto {
     final String id;
     final String name;
     
     ProductDto({required this.id, required this.name});
     
     factory ProductDto.fromJson(Map<String, dynamic> json) =>
         _$ProductDtoFromJson(json);
     Map<String, dynamic> toJson() => _$ProductDtoToJson(this);
     
     ProductEntity toEntity() => ProductEntity(id: id, name: name);
   }
   ```

2. **Create Entity** in `lib/domain/entity/`:
   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';
   part 'product_entity.freezed.dart';
   
   @freezed
   class ProductEntity with _$ProductEntity {
     const factory ProductEntity({
       required String id,
       required String name,
     }) = _ProductEntity;
   }
   ```

3. **Run code generation**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Task 2: Create a New API Service

1. **Create API service** in `lib/data/datasource/remote/`:
   ```dart
   import 'package:dio/dio.dart';
   import 'package:flutter_application/data/dto/dto.dart';
   
   class ProductApiService {
     final Dio _dio;
     
     ProductApiService(this._dio);
     
     Future<List<ProductDto>> fetchProducts() async {
       final response = await _dio.get('/products');
       return (response.data as List)
           .map((json) => ProductDto.fromJson(json))
           .toList();
     }
   }
   ```

2. **Register in DI** (`initialize_dependencies.dart`):
   ```dart
   getIt.registerLazySingleton<ProductApiService>(
     () => ProductApiService(DioClient().dio),
   );
   ```

### Task 3: Create a Repository

1. **Create interface** in `lib/domain/repository/`:
   ```dart
   abstract class ProductRepository {
     Future<List<ProductEntity>> getProducts();
   }
   ```

2. **Implement** in `lib/data/repositories/`:
   ```dart
   class ProductRepositoryImpl implements ProductRepository {
     final ProductApiService _apiService;
     
     ProductRepositoryImpl(this._apiService);
     
     @override
     Future<List<ProductEntity>> getProducts() async {
       final dtos = await _apiService.fetchProducts();
       return dtos.map((dto) => dto.toEntity()).toList();
     }
   }
   ```

3. **Register in DI**:
   ```dart
   getIt.registerLazySingleton<ProductRepository>(
     () => ProductRepositoryImpl(getIt()),
   );
   ```

### Task 4: Create a BLoC

1. **Create state** in `lib/ui/blocs/product/`:
   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';
   part 'product_state.freezed.dart';
   
   @freezed
   class ProductState with _$ProductState {
     const factory ProductState.initial() = _Initial;
     const factory ProductState.loading() = _Loading;
     const factory ProductState.loaded(List<ProductEntity> products) = _Loaded;
     const factory ProductState.error(String message) = _Error;
   }
   ```

2. **Create event**:
   ```dart
   @freezed
   class ProductEvent with _$ProductEvent {
     const factory ProductEvent.fetch() = _Fetch;
   }
   ```

3. **Create BLoC**:
   ```dart
   class ProductBloc extends Bloc<ProductEvent, ProductState> {
     final ProductRepository _repository;
     
     ProductBloc(this._repository) : super(ProductState.initial()) {
       on<_Fetch>(_onFetch);
     }
     
     Future<void> _onFetch(_Fetch event, Emitter<ProductState> emit) async {
       emit(ProductState.loading());
       try {
         final products = await _repository.getProducts();
         emit(ProductState.loaded(products));
       } catch (e) {
         emit(ProductState.error(e.toString()));
       }
     }
   }
   ```

4. **Run code generation** and **register in DI**.

> **💡 Pattern Matching with Dart 3**: When working with Freezed state classes, use **Dart 3 switch expressions** instead of the legacy `.when()` and `.map()` methods. Switch expressions provide better IDE support, exhaustive compile-time checking, and more concise syntax. See Task 5 below for examples.

### Task 5: Create a Page with BLoC

```dart
class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductBloc>()..add(ProductEvent.fetch()),
      child: Scaffold(
        appBar: AppBar(title: Text('Products')),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            return switch (state) {
              ProductStateInitial() => SizedBox.shrink(),
              ProductStateLoading() => Center(child: CircularProgressIndicator()),
              ProductStateLoaded(:final products) => ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(products[index].name));
                },
              ),
              ProductStateError(:final message) => Center(child: Text('Error: $message')),
            };
          },
        ),
      ),
    );
  }
}
```

## Validation Checklist

Before submitting your work, verify:

### Code Quality
- [ ] All code follows project naming conventions
- [ ] Architecture layers are properly separated
- [ ] No DTOs used directly in UI layer
- [ ] No direct API calls from BLoC (use repositories)
- [ ] Proper error handling implemented
- [ ] Code is properly formatted (`flutter format .`)

### Code Generation
- [ ] All generated files are up to date
- [ ] No manual edits to `.g.dart` or `.freezed.dart` files
- [ ] `build_runner` executed successfully

### Dependencies
- [ ] New dependencies added to `pubspec.yaml`
- [ ] `flutter pub get` executed successfully
- [ ] All dependencies are compatible with Flutter 3.5.0+

### Testing
- [ ] Unit tests written for business logic
- [ ] Widget tests written for new UI components
- [ ] All existing tests still pass (`flutter test`)
- [ ] Test coverage maintained or improved

### Build & Run
- [ ] Code compiles without errors (`flutter analyze`)
- [ ] No lint warnings
- [ ] App runs successfully (`flutter run`)

### Documentation
- [ ] Public APIs documented with dartdoc comments
- [ ] Complex logic explained with inline comments
- [ ] README updated if needed

## Common Pitfalls to Avoid

1. **Mixing DTOs and Entities**
   - ❌ Bad: `BlocBuilder<UserBloc, UserDto>`
   - ✅ Good: `BlocBuilder<UserBloc, UserEntity>`

2. **Direct API Calls in BLoC**
   - ❌ Bad: `final user = await apiService.fetchUser()`
   - ✅ Good: `final user = await repository.getUser()`

3. **Forgetting Code Generation**
   - ❌ Bad: Modify DTO, commit without running build_runner
   - ✅ Good: Modify DTO, run build_runner, commit all files

4. **StatefulWidget for Business State**
   - ❌ Bad: Using setState() for data from API
   - ✅ Good: Using BLoC to manage API data

5. **Hardcoded Strings**
   - ❌ Bad: `Text('Hello')`
   - ✅ Good: `Text(S.of(context).hello)`

6. **Missing Error Handling**
   - ❌ Bad: Unhandled exceptions in async operations
   - ✅ Good: Try-catch blocks with proper error states

## Quick Commands Reference

```bash
# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs
# Or use the script
bash gen.sh

# Run app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .

# Build release APK
flutter build apk --flavor production --dart-define=FLAVOR=production

# Generate assets
fluttergen -c pubspec.yaml
```

## Getting Help

- **Main instructions**: `.github/copilot-instructions.md`
- **Model/DTO patterns**: `.github/instructions/models.instructions.md`
- **UI/Widget patterns**: `.github/instructions/widgets.instructions.md`
- **API/Repository patterns**: `.github/instructions/services.instructions.md`
- **Testing patterns**: `.github/instructions/tests.instructions.md`
- **Prompt examples**: `docs/copilot-prompts.md`

## Version Compatibility

| Package | Min Version | Notes |
|---------|-------------|-------|
| Flutter | 3.5.0 | Use latest stable |
| Dart | 3.5.0 | Comes with Flutter |
| flutter_bloc | Latest | Check pub.dev |
| freezed | Latest | Code generation |
| dio | Latest | HTTP client |
| get_it | Latest | DI container |

## Final Notes

- **Be consistent**: Follow existing patterns in the codebase
- **Be thorough**: Test your changes before submitting
- **Be clean**: Keep code readable and maintainable
- **Be safe**: Never commit secrets or sensitive data
- **Be collaborative**: Ask questions if unsure

Remember: Quality over speed. It's better to take time and do it right than to rush and create technical debt.

---

**Last Updated**: 2026-02-06  
**Project Version**: 1.0.0+1  

Happy coding! 🚀

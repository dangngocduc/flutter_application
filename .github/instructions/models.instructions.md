# Models and DTOs Instructions

## Overview

This file provides comprehensive guidelines for creating and working with data models in this Flutter application. We use different patterns for different layers following Clean Architecture principles.

## Layer-Specific Model Types

### 1. Domain Layer - Entities (lib/domain/entity/)

**Purpose**: Business logic models, technology-agnostic, pure Dart classes.

**Characteristics:**
- Represent business concepts
- No external dependencies (no JSON annotations)
- Can contain business logic methods
- Immutable (use `@immutable` or `freezed`)
- Optional: Use `freezed` for complex entities with unions

**Naming Convention:**
- File: `*_entity.dart` or `*_model.dart`
- Class: `*Entity` or `*Model` suffix
- Example: `user_entity.dart` → `UserEntity`

**Example - Simple Entity:**
```dart
import 'package:flutter/foundation.dart';

@immutable
class UserEntity {
  final String id;
  final String name;
  final String email;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  // Business logic methods
  bool get isActive => createdAt != null;
  
  // copyWith for immutability
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

**Example - Entity with Freezed (Recommended for complex entities):**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String name,
    required String email,
    DateTime? createdAt,
  }) = _UserEntity;
  
  // Custom methods and getters
  const UserEntity._();
  
  bool get isActive => createdAt != null;
  String get displayName => name.toUpperCase();
}
```

### 2. Data Layer - DTOs (lib/data/dto/)

**Purpose**: Data Transfer Objects for API requests/responses and database operations.

**Characteristics:**
- Handle JSON serialization/deserialization
- Use `@JsonSerializable()` annotation
- Include `part` directive for generated code
- Implement `fromJson` factory and `toJson` method
- Should be mapped to domain entities before use in business logic

**Naming Convention:**
- File: `*_dto.dart`
- Class: `*Dto` suffix
- Example: `authentication_dto.dart` → `AuthenticationDto`

**Required Pattern:**
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  final String id;
  final String name;
  final String email;
  
  @JsonKey(name: 'created_at') // Handle snake_case from API
  final String? createdAt;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? clientOnlyField; // Exclude from JSON
  
  UserDto({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
    this.clientOnlyField,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
  
  // Mapper to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
    );
  }
  
  // Factory from domain entity (for requests)
  factory UserDto.fromEntity(UserEntity entity) {
    return UserDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      createdAt: entity.createdAt?.toIso8601String(),
    );
  }
}
```

### 3. Presentation Layer - State Classes (lib/ui/blocs/)

**Purpose**: Represent UI state in BLoC pattern.

**Characteristics:**
- Use `freezed` for union types (sealed classes)
- Immutable state representations
- Include all UI-relevant data
- Support state transitions

**Naming Convention:**
- File: `*_state.dart`
- Class: `*State` suffix
- Example: `auth_state.dart` → `AuthState`

**Required Pattern with Freezed:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_application/data/dto/dto.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authorized(ProfileDto profile) = AuthStateAuthorized;
  const factory AuthState.unAuthorized() = AuthStateUnAuthorized;
  const factory AuthState.error(String message) = AuthStateError;
}
```

**Usage in BLoC with Dart 3 Switch Expressions:**
```dart
// Exhaustive pattern matching with switch expression
return switch (state) {
  AuthStateInitial() => CircularProgressIndicator(),
  AuthStateLoading() => LoadingWidget(),
  AuthStateAuthorized(:final profile) => HomeScreen(profile: profile),
  AuthStateUnAuthorized() => LoginScreen(),
  AuthStateError(:final message) => ErrorWidget(message: message),
};

// Partial matching with default case
return switch (state) {
  AuthStateAuthorized(:final profile) => HomeScreen(profile: profile),
  _ => LoginScreen(),
};

// Alternative: Using switch statement for side effects
switch (state) {
  case AuthStateAuthorized(:final profile):
    print('User authorized: ${profile.userName}');
  case AuthStateError(:final message):
    print('Error: $message');
  default:
    print('Other state');
}
```

**Note on Legacy Pattern Matching:**
Freezed still generates `.when()`, `.maybeWhen()`, `.map()`, and `.maybeMap()` methods for backward compatibility, but Dart 3's native switch expressions are now the recommended approach for pattern matching. Switch expressions provide better IDE support, inline type safety, and are more idiomatic in modern Dart code.

## JSON Serialization with json_serializable

### Basic Annotations

**@JsonSerializable()**: Main annotation for classes
```dart
@JsonSerializable()
class MyDto {
  // fields
}
```

**@JsonKey()**: Configure individual fields
```dart
@JsonKey(name: 'api_field_name') // Map to different JSON key
final String fieldName;

@JsonKey(defaultValue: 'default') // Default value if missing
final String field;

@JsonKey(includeFromJson: false) // Skip during deserialization
final String computedField;

@JsonKey(includeToJson: false) // Skip during serialization
final String sensitiveField;

@JsonKey(ignore: true) // Skip both ways
final String internalField;

@JsonKey(required: true) // Make field required
final String mandatoryField;
```

### Handling Different Data Types

**DateTime:**
```dart
@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
final DateTime? createdAt;

static DateTime? _dateTimeFromJson(String? json) =>
    json != null ? DateTime.parse(json) : null;

static String? _dateTimeToJson(DateTime? dateTime) =>
    dateTime?.toIso8601String();
```

**Enums:**
```dart
@JsonKey(unknownEnumValue: UserRole.guest) // Default for unknown values
final UserRole role;

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('user')
  user,
  guest,
}
```

**Nested Objects:**
```dart
@JsonSerializable()
class OrderDto {
  final String id;
  final UserDto user; // Nested DTO
  final List<ProductDto> products; // List of nested DTOs
  
  OrderDto({required this.id, required this.user, required this.products});
  
  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDtoToJson(this);
}
```

### Generic DTOs

**Base Response Wrapper:**
```dart
import 'package:json_annotation/json_annotation.dart';

part 'base_response_dto.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseResponseDto<T> {
  final bool success;
  final String? message;
  final T? data;
  
  BaseResponseDto({
    required this.success,
    this.message,
    this.data,
  });

  factory BaseResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$BaseResponseDtoFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BaseResponseDtoToJson(this, toJsonT);
}
```

**Usage:**
```dart
// Parse response
final response = BaseResponseDto<UserDto>.fromJson(
  jsonData,
  (json) => UserDto.fromJson(json as Map<String, dynamic>),
);

// Or for list
final listResponse = BaseResponseDto<List<UserDto>>.fromJson(
  jsonData,
  (json) => (json as List).map((e) => UserDto.fromJson(e)).toList(),
);
```

## Using Freezed for Immutable Classes

### Basic Freezed Class

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required double price,
    @Default(0) int quantity, // Default value
  }) = _Product;
}
```

### Freezed with JSON Serialization

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart'; // For JSON serialization

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required double price,
    @Default(0) int quantity,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
```

### Freezed Union Types (Sealed Classes)

**Perfect for state management and result types:**
```dart
@freezed
class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.loading() = _Loading;
  const factory ApiResult.success(T data) = _Success<T>;
  const factory ApiResult.error(String message, [int? code]) = _Error;
}

// Usage with Dart 3 switch expressions
ApiResult<UserDto> result = await fetchUser();

switch (result) {
  case _Loading():
    showLoader();
  case _Success(:final data):
    displayUser(data);
  case _Error(:final message, :final code):
    showError(message);
}

// Or as an expression
final widget = switch (result) {
  _Loading() => LoadingWidget(),
  _Success(:final data) => UserWidget(data),
  _Error(:final message) => ErrorWidget(message),
};
```

### Custom Methods in Freezed Classes

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
  }) = _User;
  
  // Add custom constructor for custom methods
  const User._();
  
  // Custom getters and methods
  String get fullName => '$firstName $lastName';
  bool get hasValidEmail => email.contains('@');
  
  String greet() => 'Hello, $firstName!';
}
```

## Data Mapping Best Practices

### DTO to Entity Mapping

**Always map DTOs to entities before passing to domain/presentation layers:**

```dart
// In Repository implementation
class UserRepository {
  final UserApiService _apiService;
  
  Future<UserEntity> getUser(String id) async {
    final dto = await _apiService.fetchUser(id);
    return dto.toEntity(); // Map to entity
  }
  
  Future<List<UserEntity>> getUsers() async {
    final dtos = await _apiService.fetchUsers();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
```

### Entity to DTO Mapping (for requests)

```dart
class UserRepository {
  final UserApiService _apiService;
  
  Future<void> updateUser(UserEntity entity) async {
    final dto = UserDto.fromEntity(entity);
    await _apiService.updateUser(dto);
  }
}
```

## Code Generation Commands

**Generate code after creating/modifying models:**
```bash
# Full build (recommended)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter pub run build_runner watch --delete-conflicting-outputs

# Using project script
bash gen.sh
```

## Common Patterns and Examples

### Pagination Models

```dart
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int totalPages;
  final int totalItems;
  
  PaginatedResponse({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);
  
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
```

### Error Models

```dart
@JsonSerializable()
class ErrorDto {
  final String message;
  final int? code;
  final List<String>? details;
  
  ErrorDto({required this.message, this.code, this.details});
  
  factory ErrorDto.fromJson(Map<String, dynamic> json) =>
      _$ErrorDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorDtoToJson(this);
}
```

## Testing Models

### Test DTO Serialization

```dart
void main() {
  group('UserDto', () {
    test('should serialize to JSON correctly', () {
      final dto = UserDto(id: '1', name: 'John', email: 'john@example.com');
      final json = dto.toJson();
      
      expect(json['id'], '1');
      expect(json['name'], 'John');
      expect(json['email'], 'john@example.com');
    });
    
    test('should deserialize from JSON correctly', () {
      final json = {'id': '1', 'name': 'John', 'email': 'john@example.com'};
      final dto = UserDto.fromJson(json);
      
      expect(dto.id, '1');
      expect(dto.name, 'John');
      expect(dto.email, 'john@example.com');
    });
    
    test('should map to entity correctly', () {
      final dto = UserDto(id: '1', name: 'John', email: 'john@example.com');
      final entity = dto.toEntity();
      
      expect(entity, isA<UserEntity>());
      expect(entity.id, dto.id);
      expect(entity.name, dto.name);
    });
  });
}
```

## Checklist for Creating New Models

### DTO Checklist:
- [ ] Add `@JsonSerializable()` annotation
- [ ] Add `part` directive for `.g.dart` file
- [ ] Implement `fromJson` factory method
- [ ] Implement `toJson` method
- [ ] Add `@JsonKey()` annotations for special cases (snake_case, defaults, etc.)
- [ ] Implement `toEntity()` mapper method
- [ ] Implement `fromEntity()` factory if needed for requests
- [ ] Run `build_runner` to generate code
- [ ] Add tests for serialization and mapping

### Entity Checklist:
- [ ] Use `@immutable` or `freezed`
- [ ] Make all fields final
- [ ] Implement `copyWith` method (or use freezed)
- [ ] Override `==` and `hashCode` if needed (or use freezed)
- [ ] Add business logic methods if applicable
- [ ] No JSON annotations (keep it pure)
- [ ] Add tests for business logic

### State Class Checklist:
- [ ] Use `@freezed` annotation
- [ ] Add `part` directive for `.freezed.dart` file
- [ ] Define union types for different states
- [ ] Run `build_runner` to generate code
- [ ] Use in BLoC with Dart 3 switch expressions for pattern matching

## Copilot Prompts for Models

**Generate a DTO:**
> "Create a ProductDto with id, name, price, and description fields. Include JSON serialization and a toEntity mapper."

**Generate an Entity:**
> "Create a ProductEntity using freezed with id, name, price, and description. Add a method to calculate discounted price."

**Generate a State class:**
> "Create a ProductState using freezed with initial, loading, loaded(List<Product>), and error(String) states."

**Add mapper methods:**
> "Add toEntity method to ProductDto that maps to ProductEntity"

---

**Last Updated**: 2026-02-06

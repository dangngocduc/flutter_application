# Testing Instructions

## Overview

This file provides comprehensive guidelines for writing tests in this Flutter application, including unit tests, widget tests, and integration tests following best practices and the AAA (Arrange-Act-Assert) pattern.

## Testing Structure

### Directory Organization

```
test/
├── unit/               # Unit tests for business logic
│   ├── domain/
│   │   ├── entity/
│   │   └── usecase/
│   ├── data/
│   │   ├── dto/
│   │   └── repositories/
│   └── blocs/
├── widget/             # Widget tests
│   ├── pages/
│   └── widgets/
├── integration/        # Integration tests
├── fixtures/           # Test data and fixtures
│   └── test_data.dart
├── helpers/            # Test utilities
│   └── test_helpers.dart
└── mocks/              # Mock classes
    └── mocks.dart
```

## Testing Dependencies

**In pubspec.yaml:**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  bloc_test: ^9.1.0
  mocktail: ^1.0.0  # Alternative to mockito
```

## AAA Pattern (Arrange-Act-Assert)

All tests should follow the AAA pattern:

1. **Arrange**: Set up test data and mocks
2. **Act**: Execute the code under test
3. **Assert**: Verify the expected outcome

**Example:**
```dart
test('should return user when API call succeeds', () async {
  // Arrange
  final mockDto = UserDto(id: '1', name: 'John', email: 'john@test.com');
  when(mockApiService.fetchUser('1')).thenAnswer((_) async => mockDto);
  
  // Act
  final result = await repository.getUser('1');
  
  // Assert
  expect(result, isA<UserEntity>());
  expect(result.id, '1');
  expect(result.name, 'John');
});
```

## Unit Tests

### Testing DTOs and Serialization

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/data/dto/user_dto.dart';

void main() {
  group('UserDto', () {
    final testJson = {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'created_at': '2026-01-01T00:00:00.000Z',
    };
    
    test('should create UserDto from JSON', () {
      // Arrange & Act
      final dto = UserDto.fromJson(testJson);
      
      // Assert
      expect(dto.id, '1');
      expect(dto.name, 'John Doe');
      expect(dto.email, 'john@example.com');
      expect(dto.createdAt, '2026-01-01T00:00:00.000Z');
    });
    
    test('should serialize UserDto to JSON', () {
      // Arrange
      final dto = UserDto(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: '2026-01-01T00:00:00.000Z',
      );
      
      // Act
      final json = dto.toJson();
      
      // Assert
      expect(json['id'], '1');
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['created_at'], '2026-01-01T00:00:00.000Z');
    });
    
    test('should map DTO to Entity correctly', () {
      // Arrange
      final dto = UserDto(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: '2026-01-01T00:00:00.000Z',
      );
      
      // Act
      final entity = dto.toEntity();
      
      // Assert
      expect(entity, isA<UserEntity>());
      expect(entity.id, dto.id);
      expect(entity.name, dto.name);
      expect(entity.email, dto.email);
      expect(entity.createdAt, isA<DateTime>());
    });
    
    test('should handle null values correctly', () {
      // Arrange
      final jsonWithNull = {
        'id': '1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'created_at': null,
      };
      
      // Act
      final dto = UserDto.fromJson(jsonWithNull);
      
      // Assert
      expect(dto.createdAt, isNull);
    });
  });
}
```

### Testing Entities with Business Logic

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/domain/entity/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('should be active when createdAt is not null', () {
      // Arrange
      final user = UserEntity(
        id: '1',
        name: 'John',
        email: 'john@test.com',
        createdAt: DateTime.now(),
      );
      
      // Act & Assert
      expect(user.isActive, true);
    });
    
    test('should not be active when createdAt is null', () {
      // Arrange
      final user = UserEntity(
        id: '1',
        name: 'John',
        email: 'john@test.com',
        createdAt: null,
      );
      
      // Act & Assert
      expect(user.isActive, false);
    });
    
    test('should create copy with modified values', () {
      // Arrange
      final user = UserEntity(
        id: '1',
        name: 'John',
        email: 'john@test.com',
      );
      
      // Act
      final updated = user.copyWith(name: 'Jane');
      
      // Assert
      expect(updated.id, user.id);
      expect(updated.name, 'Jane');
      expect(updated.email, user.email);
    });
    
    test('should have value equality', () {
      // Arrange
      final user1 = UserEntity(
        id: '1',
        name: 'John',
        email: 'john@test.com',
      );
      final user2 = UserEntity(
        id: '1',
        name: 'Jane',
        email: 'jane@test.com',
      );
      
      // Act & Assert
      expect(user1, equals(user2)); // Same ID = equal
      expect(user1.hashCode, equals(user2.hashCode));
    });
  });
}
```

### Testing Repositories with Mocks

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_application/data/datasource/datasource.dart';
import 'package:flutter_application/data/repositories/user_repository.dart';

// Generate mocks
@GenerateMocks([UserApiService, UserLocalStorage])
import 'user_repository_test.mocks.dart';

void main() {
  late UserRepositoryImpl repository;
  late MockUserApiService mockApiService;
  late MockUserLocalStorage mockLocalStorage;
  
  setUp(() {
    mockApiService = MockUserApiService();
    mockLocalStorage = MockUserLocalStorage();
    repository = UserRepositoryImpl(
      apiService: mockApiService,
      localStorage: mockLocalStorage,
    );
  });
  
  group('UserRepository - getUser', () {
    final testDto = UserDto(
      id: '1',
      name: 'John',
      email: 'john@test.com',
    );
    
    test('should return entity from API when cache is empty', () async {
      // Arrange
      when(mockLocalStorage.getUser('1')).thenAnswer((_) async => null);
      when(mockApiService.fetchUser('1')).thenAnswer((_) async => testDto);
      when(mockLocalStorage.saveUser(any)).thenAnswer((_) async => {});
      
      // Act
      final result = await repository.getUser('1');
      
      // Assert
      expect(result, isA<UserEntity>());
      expect(result.id, '1');
      expect(result.name, 'John');
      
      // Verify call order
      verify(mockLocalStorage.getUser('1')).called(1);
      verify(mockApiService.fetchUser('1')).called(1);
      verify(mockLocalStorage.saveUser(testDto)).called(1);
    });
    
    test('should return entity from cache when available', () async {
      // Arrange
      when(mockLocalStorage.getUser('1')).thenAnswer((_) async => testDto);
      
      // Act
      final result = await repository.getUser('1');
      
      // Assert
      expect(result.id, '1');
      
      // Verify API was not called
      verify(mockLocalStorage.getUser('1')).called(1);
      verifyNever(mockApiService.fetchUser(any));
    });
    
    test('should throw exception when API call fails', () async {
      // Arrange
      when(mockLocalStorage.getUser('1')).thenAnswer((_) async => null);
      when(mockApiService.fetchUser('1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/1'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      
      // Act & Assert
      expect(
        () => repository.getUser('1'),
        throwsA(isA<Exception>()),
      );
    });
  });
  
  group('UserRepository - createUser', () {
    test('should create user and return entity', () async {
      // Arrange
      final entity = UserEntity(
        id: '1',
        name: 'John',
        email: 'john@test.com',
      );
      final dto = UserDto.fromEntity(entity);
      
      when(mockApiService.createUser(any)).thenAnswer((_) async => dto);
      
      // Act
      final result = await repository.createUser(entity);
      
      // Assert
      expect(result, isA<UserEntity>());
      expect(result.id, entity.id);
      
      // Verify DTO conversion
      final captured = verify(
        mockApiService.createUser(captureAny),
      ).captured.single as UserDto;
      expect(captured.id, entity.id);
      expect(captured.name, entity.name);
    });
  });
  
  group('UserRepository - deleteUser', () {
    test('should delete from both API and cache', () async {
      // Arrange
      when(mockApiService.deleteUser('1')).thenAnswer((_) async => {});
      when(mockLocalStorage.deleteUser('1')).thenAnswer((_) async => {});
      
      // Act
      await repository.deleteUser('1');
      
      // Assert
      verify(mockApiService.deleteUser('1')).called(1);
      verify(mockLocalStorage.deleteUser('1')).called(1);
    });
  });
}
```

### Testing BLoCs with bloc_test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_application/ui/blocs/auth/auth_bloc.dart';

@GenerateMocks([AuthRepository])
import 'auth_bloc_test.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    authBloc = AuthBloc(mockRepository);
  });
  
  tearDown(() {
    authBloc.close();
  });
  
  group('AuthBloc', () {
    final testProfile = ProfileDto(
      id: '1',
      name: 'John',
      email: 'john@test.com',
    );
    
    blocTest<AuthBloc, AuthState>(
      'should emit [loading, authorized] when login succeeds',
      build: () {
        when(mockRepository.login(any, any)).thenAnswer(
          (_) async => testProfile,
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        AuthEvent.login('username', 'password'),
      ),
      expect: () => [
        AuthState.loading(),
        AuthState.authorized(testProfile),
      ],
      verify: (_) {
        verify(mockRepository.login('username', 'password')).called(1);
      },
    );
    
    blocTest<AuthBloc, AuthState>(
      'should emit [loading, error] when login fails',
      build: () {
        when(mockRepository.login(any, any)).thenThrow(
          Exception('Invalid credentials'),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        AuthEvent.login('username', 'wrong'),
      ),
      expect: () => [
        AuthState.loading(),
        AuthState.error('Invalid credentials'),
      ],
    );
    
    blocTest<AuthBloc, AuthState>(
      'should emit [unAuthorized] when logout is called',
      build: () {
        when(mockRepository.logout()).thenAnswer((_) async => {});
        return authBloc;
      },
      seed: () => AuthState.authorized(testProfile),
      act: (bloc) => bloc.add(AuthEvent.logout()),
      expect: () => [
        AuthState.unAuthorized(),
      ],
      verify: (_) {
        verify(mockRepository.logout()).called(1);
      },
    );
  });
}
```

## Widget Tests

### Testing StatelessWidget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/ui/widgets/user_profile_card.dart';

void main() {
  group('UserProfileCard', () {
    testWidgets('should display user name and email', (tester) async {
      // Arrange
      const name = 'John Doe';
      const email = 'john@example.com';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserProfileCard(
              name: name,
              email: email,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(name), findsOneWidget);
      expect(find.text(email), findsOneWidget);
    });
    
    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserProfileCard(
              name: 'John',
              email: 'john@test.com',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      
      // Act
      await tester.tap(find.byType(UserProfileCard));
      await tester.pump();
      
      // Assert
      expect(tapped, true);
    });
    
    testWidgets('should render with correct styling', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserProfileCard(
              name: 'John',
              email: 'john@test.com',
            ),
          ),
        ),
      );
      
      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card, isNotNull);
      
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.title, isA<Text>());
      expect(listTile.subtitle, isA<Text>());
    });
  });
}
```

### Testing Page with BLoC

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_application/ui/pages/signin/sign_in_page.dart';
import 'package:flutter_application/ui/blocs/auth/auth_bloc.dart';

// Mock BLoC
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> 
    implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  
  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });
  
  tearDown(() {
    mockAuthBloc.close();
  });
  
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (_) => mockAuthBloc,
        child: child,
      ),
    );
  }
  
  group('SignInPage', () {
    testWidgets('should display login form when unAuthorized', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthState.unAuthorized());
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthState.unAuthorized()]),
      );
      
      // Act
      await tester.pumpWidget(createTestWidget(SignInPage()));
      
      // Assert
      expect(find.byType(TextFormField), findsNWidgets(2)); // Username & password
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
    
    testWidgets('should display loading indicator when loading', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthState.loading());
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthState.loading()]),
      );
      
      // Act
      await tester.pumpWidget(createTestWidget(SignInPage()));
      await tester.pump();
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should trigger login event when submit button pressed', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthState.unAuthorized());
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthState.unAuthorized()]),
      );
      
      await tester.pumpWidget(createTestWidget(SignInPage()));
      
      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'testuser',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Assert
      verify(
        () => mockAuthBloc.add(
          AuthEvent.login('testuser', 'password123'),
        ),
      ).called(1);
    });
    
    testWidgets('should show error message when error state', (tester) async {
      // Arrange
      const errorMessage = 'Login failed';
      when(() => mockAuthBloc.state).thenReturn(AuthState.error(errorMessage));
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          AuthState.unAuthorized(),
          AuthState.error(errorMessage),
        ]),
      );
      
      await tester.pumpWidget(createTestWidget(SignInPage()));
      
      // Act
      await tester.pump();
      
      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });
  });
}
```

### Testing Forms

```dart
testWidgets('should validate form fields', (tester) async {
  // Arrange
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SignInForm())),
  );
  
  // Act - Try to submit with empty fields
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  // Assert
  expect(find.text('Please enter username'), findsOneWidget);
  expect(find.text('Please enter password'), findsOneWidget);
});

testWidgets('should validate password length', (tester) async {
  // Arrange
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SignInForm())),
  );
  
  // Act
  await tester.enterText(find.byType(TextFormField).last, '12345');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  // Assert
  expect(
    find.text('Password must be at least 6 characters'),
    findsOneWidget,
  );
});
```

### Testing Lists

```dart
testWidgets('should display list of users', (tester) async {
  // Arrange
  final users = [
    UserEntity(id: '1', name: 'John', email: 'john@test.com'),
    UserEntity(id: '2', name: 'Jane', email: 'jane@test.com'),
    UserEntity(id: '3', name: 'Bob', email: 'bob@test.com'),
  ];
  
  when(() => mockUserBloc.state).thenReturn(UserState.loaded(users));
  whenListen(mockUserBloc, Stream.fromIterable([UserState.loaded(users)]));
  
  // Act
  await tester.pumpWidget(createTestWidget(UserListPage()));
  
  // Assert
  expect(find.text('John'), findsOneWidget);
  expect(find.text('Jane'), findsOneWidget);
  expect(find.text('Bob'), findsOneWidget);
});

testWidgets('should scroll to bottom of list', (tester) async {
  // Arrange
  final users = List.generate(
    50,
    (i) => UserEntity(id: '$i', name: 'User $i', email: 'user$i@test.com'),
  );
  
  when(() => mockUserBloc.state).thenReturn(UserState.loaded(users));
  
  await tester.pumpWidget(createTestWidget(UserListPage()));
  
  // Act
  await tester.drag(find.byType(ListView), Offset(0, -10000));
  await tester.pumpAndSettle();
  
  // Assert
  expect(find.text('User 49'), findsOneWidget);
});
```

## Integration Tests

```dart
// test/integration/auth_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Authentication Flow', () {
    testWidgets('complete login flow', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Act - Navigate to login
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      
      // Enter credentials
      await tester.enterText(
        find.byKey(Key('username_field')),
        'testuser',
      );
      await tester.enterText(
        find.byKey(Key('password_field')),
        'password123',
      );
      
      // Submit
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Assert - Should navigate to home
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
```

## Test Helpers and Fixtures

### Test Data Fixtures

```dart
// test/fixtures/test_data.dart
import 'package:flutter_application/data/dto/user_dto.dart';
import 'package:flutter_application/domain/entity/user_entity.dart';

class TestData {
  static UserDto userDto({
    String id = '1',
    String name = 'Test User',
    String email = 'test@example.com',
  }) {
    return UserDto(
      id: id,
      name: name,
      email: email,
    );
  }
  
  static UserEntity userEntity({
    String id = '1',
    String name = 'Test User',
    String email = 'test@example.com',
  }) {
    return UserEntity(
      id: id,
      name: name,
      email: email,
    );
  }
  
  static List<UserDto> userDtoList(int count) {
    return List.generate(
      count,
      (i) => userDto(
        id: '$i',
        name: 'User $i',
        email: 'user$i@test.com',
      ),
    );
  }
}
```

### Test Widget Wrapper

```dart
// test/helpers/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestHelpers {
  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }
  
  static Widget wrapWithBloc<B extends Bloc>(
    B bloc,
    Widget child,
  ) {
    return MaterialApp(
      home: BlocProvider<B>(
        create: (_) => bloc,
        child: Scaffold(body: child),
      ),
    );
  }
  
  static Widget wrapWithMultipleBlocs(
    List<BlocProvider> providers,
    Widget child,
  ) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: providers,
        child: Scaffold(body: child),
      ),
    );
  }
}
```

## Test Coverage

**Run tests with coverage:**
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

## Best Practices

### Do's
- ✅ Follow AAA pattern (Arrange-Act-Assert)
- ✅ Use descriptive test names
- ✅ Test one thing per test
- ✅ Use mocks for external dependencies
- ✅ Test both success and failure cases
- ✅ Test edge cases and boundary conditions
- ✅ Use setUp and tearDown for common setup
- ✅ Clean up resources (close BLoCs, dispose controllers)
- ✅ Use const constructors in test widgets where possible
- ✅ Group related tests together

### Don'ts
- ❌ Don't test implementation details
- ❌ Don't write tests that depend on other tests
- ❌ Don't use real network calls (mock them)
- ❌ Don't ignore failing tests
- ❌ Don't test framework code (Flutter widgets, etc.)
- ❌ Don't write overly complex tests
- ❌ Don't forget to test error handling

## Copilot Prompts for Tests

**Generate unit test for DTO:**
> "Create unit tests for UserDto including JSON serialization, deserialization, and entity mapping"

**Generate repository test:**
> "Create unit tests for UserRepository with mocks for API service and local storage"

**Generate BLoC test:**
> "Create BLoC tests for AuthBloc using bloc_test package covering login, logout, and error states"

**Generate widget test:**
> "Create widget tests for SignInPage including form validation and BLoC integration"

---

**Last Updated**: 2026-02-06

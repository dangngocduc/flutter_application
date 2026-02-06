# Services, API, and Repository Instructions

## Overview

This file provides comprehensive guidelines for implementing data sources, API services, and repositories following Clean Architecture principles. The data layer handles all external data operations and maps DTOs to domain entities.

## Architecture Layers

### Data Flow

```
UI (Presentation) → BLoC → Repository (Domain) → Repository Implementation (Data) → API Service / Local Storage → External Sources
                      ↑                              ↓
                   Entities                        DTOs
```

## Repository Pattern

### 1. Repository Interface (Domain Layer)

**Location**: `lib/domain/repository/`

**Purpose**: Define contracts for data operations (technology-agnostic)

**Pattern:**
```dart
// lib/domain/repository/user_repository.dart
abstract class UserRepository {
  Future<UserEntity> getUser(String id);
  Future<List<UserEntity>> getUsers();
  Future<UserEntity> createUser(UserEntity user);
  Future<UserEntity> updateUser(String id, UserEntity user);
  Future<void> deleteUser(String id);
  Stream<List<UserEntity>> watchUsers();
}
```

### 2. Repository Implementation (Data Layer)

**Location**: `lib/data/repositories/`

**Purpose**: Implement domain repository interfaces, coordinate data sources, map DTOs to entities

**Pattern:**
```dart
// lib/data/repositories/user_repository.dart
import 'package:flutter_application/data/datasource/datasource.dart';
import 'package:flutter_application/data/dto/dto.dart';
import 'package:flutter_application/domain/entity/entity.dart';
import 'package:flutter_application/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApiService _apiService;
  final UserLocalStorage? _localStorage;
  
  UserRepositoryImpl({
    required UserApiService apiService,
    UserLocalStorage? localStorage,
  })  : _apiService = apiService,
        _localStorage = localStorage;

  @override
  Future<UserEntity> getUser(String id) async {
    try {
      // Try cache first
      final cached = await _localStorage?.getUser(id);
      if (cached != null) {
        return cached.toEntity();
      }
      
      // Fetch from API
      final dto = await _apiService.fetchUser(id);
      
      // Save to cache
      await _localStorage?.saveUser(dto);
      
      // Map to entity
      return dto.toEntity();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<List<UserEntity>> getUsers() async {
    try {
      final dtos = await _apiService.fetchUsers();
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<UserEntity> createUser(UserEntity user) async {
    try {
      final dto = UserDto.fromEntity(user);
      final result = await _apiService.createUser(dto);
      return result.toEntity();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<UserEntity> updateUser(String id, UserEntity user) async {
    try {
      final dto = UserDto.fromEntity(user);
      final result = await _apiService.updateUser(id, dto);
      
      // Update cache
      await _localStorage?.saveUser(result);
      
      return result.toEntity();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<void> deleteUser(String id) async {
    try {
      await _apiService.deleteUser(id);
      await _localStorage?.deleteUser(id);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Stream<List<UserEntity>> watchUsers() {
    return _apiService.watchUsers().map(
      (dtos) => dtos.map((dto) => dto.toEntity()).toList(),
    );
  }
  
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }
    return Exception('Unknown error: $error');
  }
  
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${error.response?.statusCode}');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error');
    }
  }
}
```

## API Services (Remote Data Sources)

### Location: `lib/data/datasource/remote/`

### Dio Configuration

**Base setup:**
```dart
// lib/data/datasource/remote/dio_client.dart
import 'package:dio/dio.dart';
import 'package:oauth2_dio/oauth2_dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();
  
  late Dio _dio;
  
  Dio get dio => _dio;
  
  void initialize({
    required String baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    
    // Add authentication interceptor if using OAuth2
    // _dio.interceptors.add(OAuth2Interceptor(...));
  }
}
```

### API Service Pattern

**Without Retrofit (Manual):**
```dart
// lib/data/datasource/remote/user_api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_application/data/dto/dto.dart';
import 'package:flutter_application/data/datasource/remote/dio_client.dart';

class UserApiService {
  final Dio _dio = DioClient().dio;
  
  static const String _baseEndpoint = '/users';
  
  Future<UserDto> fetchUser(String id) async {
    try {
      final response = await _dio.get('$_baseEndpoint/$id');
      return UserDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<UserDto>> fetchUsers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        _baseEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      final List<dynamic> data = response.data['items'] ?? response.data;
      return data.map((json) => UserDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<UserDto> createUser(UserDto user) async {
    try {
      final response = await _dio.post(
        _baseEndpoint,
        data: user.toJson(),
      );
      return UserDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<UserDto> updateUser(String id, UserDto user) async {
    try {
      final response = await _dio.put(
        '$_baseEndpoint/$id',
        data: user.toJson(),
      );
      return UserDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete('$_baseEndpoint/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    if (error.response != null) {
      // Handle HTTP errors
      switch (error.response!.statusCode) {
        case 400:
          return Exception('Bad request');
        case 401:
          return Exception('Unauthorized');
        case 403:
          return Exception('Forbidden');
        case 404:
          return Exception('Not found');
        case 500:
          return Exception('Server error');
        default:
          return Exception('HTTP ${error.response!.statusCode}');
      }
    } else {
      // Handle connection errors
      if (error.type == DioExceptionType.connectionTimeout) {
        return Exception('Connection timeout');
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return Exception('Receive timeout');
      } else {
        return Exception('Network error');
      }
    }
  }
}
```

### API Response Handling

**Generic Response Wrapper:**
```dart
Future<T> _handleRequest<T>(
  Future<Response> Function() request,
  T Function(dynamic data) parser,
) async {
  try {
    final response = await request();
    
    // Handle wrapped responses
    if (response.data is Map<String, dynamic>) {
      final data = response.data;
      
      if (data.containsKey('success') && data['success'] == false) {
        throw Exception(data['message'] ?? 'Request failed');
      }
      
      final result = data['data'] ?? data;
      return parser(result);
    }
    
    return parser(response.data);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

// Usage
Future<UserDto> fetchUser(String id) {
  return _handleRequest(
    () => _dio.get('$_baseEndpoint/$id'),
    (data) => UserDto.fromJson(data),
  );
}

Future<List<UserDto>> fetchUsers() {
  return _handleRequest(
    () => _dio.get(_baseEndpoint),
    (data) => (data as List).map((json) => UserDto.fromJson(json)).toList(),
  );
}
```

### Handling Pagination

```dart
class PaginatedApiService {
  Future<PaginatedResponse<UserDto>> fetchUsersPaginated({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/users',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      return PaginatedResponse<UserDto>.fromJson(
        response.data,
        (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

// In repository
Future<List<UserEntity>> getUsersPaginated(int page) async {
  final response = await _apiService.fetchUsersPaginated(page: page);
  return response.items.map((dto) => dto.toEntity()).toList();
}
```

## Local Data Sources

### Location: `lib/data/datasource/local/`

### SharedPreferences Pattern

```dart
// lib/data/datasource/local/user_local_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application/data/dto/dto.dart';

class UserLocalStorage {
  static const String _keyPrefix = 'user_';
  static const String _keyUserList = 'users_list';
  
  final SharedPreferences _prefs;
  
  UserLocalStorage(this._prefs);
  
  // Save single user
  Future<void> saveUser(UserDto user) async {
    final key = '$_keyPrefix${user.id}';
    final json = jsonEncode(user.toJson());
    await _prefs.setString(key, json);
  }
  
  // Get single user
  Future<UserDto?> getUser(String id) async {
    final key = '$_keyPrefix$id';
    final json = _prefs.getString(key);
    
    if (json == null) return null;
    
    try {
      return UserDto.fromJson(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }
  
  // Save user list
  Future<void> saveUsers(List<UserDto> users) async {
    final jsonList = users.map((user) => user.toJson()).toList();
    final json = jsonEncode(jsonList);
    await _prefs.setString(_keyUserList, json);
  }
  
  // Get user list
  Future<List<UserDto>?> getUsers() async {
    final json = _prefs.getString(_keyUserList);
    
    if (json == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(json);
      return jsonList.map((json) => UserDto.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }
  
  // Delete user
  Future<void> deleteUser(String id) async {
    final key = '$_keyPrefix$id';
    await _prefs.remove(key);
  }
  
  // Clear all users
  Future<void> clearUsers() async {
    final keys = _prefs.getKeys()
        .where((key) => key.startsWith(_keyPrefix))
        .toList();
    
    for (final key in keys) {
      await _prefs.remove(key);
    }
    
    await _prefs.remove(_keyUserList);
  }
  
  // Save simple values
  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }
  
  String? getToken() {
    return _prefs.getString('auth_token');
  }
  
  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }
}
```

### Cache Strategy

**Time-based cache:**
```dart
class CachedUserStorage {
  final UserLocalStorage _localStorage;
  final Duration _cacheExpiration;
  
  CachedUserStorage(this._localStorage, {
    Duration? cacheExpiration,
  }) : _cacheExpiration = cacheExpiration ?? Duration(minutes: 5);
  
  Future<UserDto?> getUser(String id) async {
    final cached = await _localStorage.getUser(id);
    
    if (cached == null) return null;
    
    // Check if cache is expired (you'd need to store timestamp)
    final cacheTime = await _getCacheTime(id);
    if (cacheTime != null) {
      final age = DateTime.now().difference(cacheTime);
      if (age > _cacheExpiration) {
        await _localStorage.deleteUser(id);
        return null;
      }
    }
    
    return cached;
  }
  
  Future<void> saveUser(UserDto user) async {
    await _localStorage.saveUser(user);
    await _saveCacheTime(user.id);
  }
  
  Future<DateTime?> _getCacheTime(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('cache_time_$id');
    return timestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(timestamp) 
        : null;
  }
  
  Future<void> _saveCacheTime(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'cache_time_$id',
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
```

## Authentication Pattern (OAuth2)

### Using oauth2_dio Package

```dart
// lib/data/datasource/remote/auth_api_service.dart
import 'package:dio/dio.dart';
import 'package:oauth2_dio/oauth2_dio.dart';
import 'package:flutter_application/data/dto/dto.dart';

class AuthApiService {
  final Dio _dio;
  late OAuth2Dio _oauth2Dio;
  
  AuthApiService(this._dio) {
    _initializeOAuth();
  }
  
  void _initializeOAuth() {
    _oauth2Dio = OAuth2Dio(
      oauth2Storage: CustomOAuth2Storage(), // Implement storage
      clientId: 'your_client_id',
      clientSecret: 'your_client_secret',
    );
    
    _dio.interceptors.add(_oauth2Dio);
  }
  
  Future<AuthenticationDto> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      
      final authDto = AuthenticationDto.fromJson(response.data);
      
      // Store tokens
      await _oauth2Dio.storage.save(authDto);
      
      return authDto;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> logout() async {
    await _oauth2Dio.storage.clear();
    // Call logout endpoint if needed
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Ignore errors during logout
    }
  }
  
  Future<ProfileDto> profile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return ProfileDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> refreshToken() async {
    await _oauth2Dio.refreshAccessToken();
  }
  
  Exception _handleError(DioException error) {
    // Error handling
    return Exception('Auth error: ${error.message}');
  }
}
```

## Error Handling Patterns

### Custom Exception Classes

```dart
// lib/data/exceptions/api_exception.dart
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([String? message]) 
      : super(message ?? 'Network error');
}

class ServerException extends ApiException {
  ServerException([String? message, int? statusCode]) 
      : super(message ?? 'Server error', statusCode);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String? message]) 
      : super(message ?? 'Unauthorized', 401);
}

class NotFoundException extends ApiException {
  NotFoundException([String? message]) 
      : super(message ?? 'Not found', 404);
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;
  
  ValidationException(String message, [this.errors]) 
      : super(message, 422);
}
```

### Error Handler Service

```dart
class ApiErrorHandler {
  static Exception handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      
      final message = _extractMessage(data);
      
      switch (statusCode) {
        case 400:
          return ValidationException(message);
        case 401:
          return UnauthorizedException(message);
        case 403:
          return ServerException('Forbidden', 403);
        case 404:
          return NotFoundException(message);
        case 422:
          final errors = _extractValidationErrors(data);
          return ValidationException(message, errors);
        case 500:
        case 502:
        case 503:
          return ServerException(message, statusCode);
        default:
          return ServerException('HTTP $statusCode: $message', statusCode);
      }
    }
    
    // Connection errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout');
      case DioExceptionType.cancel:
        return NetworkException('Request cancelled');
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection');
      default:
        return NetworkException('Network error: ${error.message}');
    }
  }
  
  static String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? 'Unknown error';
    }
    return 'Unknown error';
  }
  
  static Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.map(
          (key, value) => MapEntry(
            key,
            (value as List).map((e) => e.toString()).toList(),
          ),
        );
      }
    }
    return null;
  }
}
```

## Dependency Injection Setup

### Registering Services and Repositories

```dart
// lib/initialize_dependencies.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application/data/datasource/datasource.dart';
import 'package:flutter_application/data/repositories/repositories.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  // Initialize Dio
  DioClient().initialize(baseUrl: 'https://api.example.com');
  
  // Register local storages
  getIt.registerLazySingleton<UserLocalStorage>(
    () => UserLocalStorage(getIt()),
  );
  
  // Register API services
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(DioClient().dio),
  );
  
  getIt.registerLazySingleton<UserApiService>(
    () => UserApiService(),
  );
  
  // Register repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(),
  );
  
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      apiService: getIt(),
      localStorage: getIt(),
    ),
  );
  
  // Register BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt()));
  getIt.registerFactory<UserBloc>(() => UserBloc(getIt()));
}
```

## Testing Services and Repositories

### Mocking API Service

```dart
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockUserApiService extends Mock implements UserApiService {}
class MockUserLocalStorage extends Mock implements UserLocalStorage {}

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
  
  group('UserRepository', () {
    test('should return user entity from API', () async {
      // Arrange
      final dto = UserDto(id: '1', name: 'John', email: 'john@test.com');
      when(mockApiService.fetchUser('1')).thenAnswer((_) async => dto);
      
      // Act
      final result = await repository.getUser('1');
      
      // Assert
      expect(result, isA<UserEntity>());
      expect(result.id, '1');
      expect(result.name, 'John');
      verify(mockApiService.fetchUser('1')).called(1);
    });
    
    test('should use cache when available', () async {
      // Arrange
      final dto = UserDto(id: '1', name: 'John', email: 'john@test.com');
      when(mockLocalStorage.getUser('1')).thenAnswer((_) async => dto);
      
      // Act
      final result = await repository.getUser('1');
      
      // Assert
      expect(result.id, '1');
      verifyNever(mockApiService.fetchUser('1'));
      verify(mockLocalStorage.getUser('1')).called(1);
    });
  });
}
```

## Copilot Prompts for Services

**Generate API service:**
> "Create a ProductApiService with methods to fetch, create, update, and delete products using Dio"

**Generate repository:**
> "Create a ProductRepositoryImpl that implements ProductRepository, uses ProductApiService, maps DTOs to entities, and handles errors"

**Add error handling:**
> "Add comprehensive error handling to UserApiService with custom exceptions for different HTTP status codes"

---

**Last Updated**: 2026-02-06

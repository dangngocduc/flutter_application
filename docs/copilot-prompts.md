# GitHub Copilot Prompt Examples and Templates

## Introduction

This document provides curated, production-ready prompt examples for common development tasks in this Flutter application. Use these prompts with GitHub Copilot Chat or CLI to accelerate development while maintaining consistency and quality.

## Table of Contents

1. [Model and DTO Creation](#model-and-dto-creation)
2. [API Services](#api-services)
3. [Repositories](#repositories)
4. [BLoC and State Management](#bloc-and-state-management)
5. [UI Components](#ui-components)
6. [Navigation](#navigation)
7. [Testing](#testing)
8. [Debugging](#debugging)
9. [Refactoring](#refactoring)
10. [Migration and Updates](#migration-and-updates)

---

## Model and DTO Creation

### Create a Complete DTO with JSON Serialization

**Prompt:**
```
Create a ProductDto class in lib/data/dto/product_dto.dart with the following fields:
- id (String, required)
- name (String, required)
- description (String, optional)
- price (double, required)
- categoryId (String, required, mapped from "category_id" in JSON)
- imageUrl (String, optional, mapped from "image_url")
- createdAt (String, optional, mapped from "created_at")

Include:
- @JsonSerializable() annotation
- part directive for generated file
- fromJson factory method
- toJson method
- toEntity() method that maps to ProductEntity
- fromEntity() factory method for requests
```

### Create a Domain Entity with Freezed

**Prompt:**
```
Create a ProductEntity class in lib/domain/entity/product_entity.dart using freezed with:
- id (String)
- name (String)
- description (String?)
- price (double)
- categoryId (String)
- imageUrl (String?)
- createdAt (DateTime?)

Include:
- Custom constructor for methods
- A getter "displayPrice" that formats price as currency
- A getter "hasImage" that checks if imageUrl is not null
- A method "isExpensive()" that returns true if price > 100
```

### Create a State Class with Union Types

**Prompt:**
```
Create a ProductState class in lib/ui/blocs/product/product_state.dart using freezed with union types:
- initial()
- loading()
- loaded(List<ProductEntity> products, {int? totalCount})
- empty(String message)
- error(String message, {int? errorCode})

Include part directive for generated file.
```

### Create an Event Class

**Prompt:**
```
Create a ProductEvent class in lib/ui/blocs/product/product_event.dart using freezed with union types:
- fetch()
- refresh()
- fetchById(String id)
- create(ProductEntity product)
- update(String id, ProductEntity product)
- delete(String id)
- search(String query)
```

---

## API Services

### Create a REST API Service

**Prompt:**
```
Create a ProductApiService class in lib/data/datasource/remote/product_api_service.dart with:
- Dio instance from DioClient
- Base endpoint "/products"
- Methods:
  - fetchProducts() returns List<ProductDto>
  - fetchProduct(String id) returns ProductDto
  - createProduct(ProductDto product) returns ProductDto
  - updateProduct(String id, ProductDto product) returns ProductDto
  - deleteProduct(String id) returns void
  - searchProducts(String query) returns List<ProductDto>
  - fetchProductsByCategory(String categoryId) returns List<ProductDto>

Include:
- Proper error handling with DioException
- Query parameters for pagination and search
- Custom error messages for different HTTP status codes
```

### Add Pagination to API Service

**Prompt:**
```
Update ProductApiService.fetchProducts() to support pagination with:
- Parameters: page (default 1), limit (default 20)
- Return type: PaginatedResponse<ProductDto>
- Query parameters sent to API
- Proper error handling
```

### Add Authentication Headers

**Prompt:**
```
Create an interceptor in lib/data/datasource/remote/auth_interceptor.dart that:
- Adds Authorization header with Bearer token from local storage
- Refreshes token if 401 response received
- Retries original request with new token
- Logs out user if refresh fails
```

---

## Repositories

### Create a Complete Repository

**Prompt:**
```
Create ProductRepository interface in lib/domain/repository/product_repository.dart with methods:
- Future<List<ProductEntity>> getProducts({int page, int limit})
- Future<ProductEntity> getProduct(String id)
- Future<ProductEntity> createProduct(ProductEntity product)
- Future<ProductEntity> updateProduct(String id, ProductEntity product)
- Future<void> deleteProduct(String id)
- Stream<List<ProductEntity>> watchProducts()

Then create ProductRepositoryImpl in lib/data/repositories/product_repository.dart that:
- Implements the interface
- Uses ProductApiService for remote data
- Uses ProductLocalStorage for caching
- Maps DTOs to entities
- Handles errors with custom exceptions
- Caches products locally
- Returns cached data if network fails
```

### Add Caching Strategy

**Prompt:**
```
Update ProductRepositoryImpl to implement a caching strategy:
- Check local cache first (ProductLocalStorage)
- Return cached data if fresh (within 5 minutes)
- Fetch from API if cache expired or missing
- Save API response to cache
- Return entity
Include cache timestamp management and cache invalidation methods.
```

---

## BLoC and State Management

### Create a Complete BLoC

**Prompt:**
```
Create a ProductBloc in lib/ui/blocs/product/product_bloc.dart that:
- Uses ProductRepository
- Handles ProductEvent
- Emits ProductState
- Implements handlers for:
  - fetch: Load products list
  - fetchById: Load single product
  - create: Create new product
  - update: Update existing product
  - delete: Delete product
  - search: Search products
- Includes proper error handling
- Emits loading states before async operations
- Emits error states with messages
```

### Add Debouncing for Search

**Prompt:**
```
Update ProductBloc to add debounced search functionality:
- Debounce search events by 500ms using stream_transform
- Cancel previous search if new one starts
- Emit loading state while searching
- Handle empty search results
```

### Create BLoC with Pagination

**Prompt:**
```
Create a ProductListBloc with pagination support:
- State includes: products list, page number, hasMore, isLoading
- Events: loadInitial, loadMore, refresh
- Implement infinite scroll pattern
- Prevent duplicate loads
- Handle end of list
```

---

## UI Components

### Create a List Page with BLoC

**Prompt:**
```
Create a ProductListPage in lib/ui/pages/product/product_list_page.dart that:
- Uses ProductBloc with BlocProvider
- Shows loading indicator when loading
- Displays ListView of products when loaded
- Shows empty state with custom message
- Shows error with retry button
- Has floating action button to add new product
- Implements pull-to-refresh
- Includes search bar in app bar
```

### Create a Reusable Card Widget

**Prompt:**
```
Create a ProductCard widget in lib/ui/widgets/product_card_widget.dart that:
- Takes ProductEntity as parameter
- Displays product image (or placeholder if null)
- Shows product name, price, and description
- Has an onTap callback
- Has an optional delete button with confirmation
- Uses Card with elevation
- Implements responsive design
- Shows formatted price with currency symbol
```

### Create a Form Page

**Prompt:**
```
Create a ProductFormPage in lib/ui/pages/product/product_form_page.dart that:
- Has form fields for: name, description, price, categoryId
- Validates all required fields
- Validates price is a valid number
- Has save button that dispatches create/update event to BLoC
- Shows loading state during save
- Navigates back on success
- Shows error snackbar on failure
- Pre-fills form if editing existing product
```

### Create a Detail Page

**Prompt:**
```
Create a ProductDetailPage in lib/ui/pages/product/product_detail_page.dart that:
- Takes product ID as parameter
- Uses ProductBloc to fetch product by ID
- Shows loading indicator while fetching
- Displays full product details with image
- Has edit button that navigates to form page
- Has delete button with confirmation dialog
- Shows formatted price
- Handles errors gracefully
```

### Create a Search Widget

**Prompt:**
```
Create a ProductSearchBar widget that:
- Has TextFormField for search input
- Debounces input by 500ms
- Calls onSearch callback with query
- Has clear button that appears when text entered
- Shows search icon
- Has hint text "Search products..."
```

---

## Navigation

### Add Navigation to Detail Page

**Prompt:**
```
Add navigation from ProductCard to ProductDetailPage when tapped:
- Pass product ID as argument
- Use MaterialPageRoute
- Refresh product list when returning if product was edited
```

### Implement Bottom Navigation

**Prompt:**
```
Create a MainPage with BottomNavigationBar that has 4 tabs:
- Home (ProductListPage)
- Categories (CategoriesPage)
- Cart (CartPage)
- Profile (ProfilePage)
Use IndexedStack to preserve state between tab switches.
```

### Add Named Routes

**Prompt:**
```
Create a routes.dart file in lib/ with named routes for:
- '/': HomePage
- '/login': SignInPage
- '/products': ProductListPage
- '/products/:id': ProductDetailPage
- '/products/create': ProductFormPage
- '/products/:id/edit': ProductFormPage with edit mode

Include route generator function that handles arguments.
```

---

## Testing

### Create DTO Tests

**Prompt:**
```
Create unit tests for ProductDto in test/unit/data/dto/product_dto_test.dart:
- Test fromJson deserialization with valid data
- Test toJson serialization
- Test fromJson with missing optional fields
- Test toJson with null optional fields
- Test toEntity mapping
- Test fromEntity mapping
- Use AAA pattern (Arrange-Act-Assert)
```

### Create Repository Tests

**Prompt:**
```
Create unit tests for ProductRepositoryImpl in test/unit/data/repositories/product_repository_test.dart using mockito:
- Mock ProductApiService and ProductLocalStorage
- Test getProducts() returns entities from API
- Test getProducts() uses cache when available
- Test getProducts() saves to cache after API call
- Test getProduct() handles network errors
- Test createProduct() calls API and maps correctly
- Test deleteProduct() removes from both API and cache
- Use AAA pattern and verify mock calls
```

### Create BLoC Tests

**Prompt:**
```
Create BLoC tests for ProductBloc in test/unit/blocs/product_bloc_test.dart using bloc_test:
- Test initial state
- Test fetch event emits [loading, loaded] when successful
- Test fetch event emits [loading, error] when fails
- Test create event emits [loading, loaded] with updated list
- Test delete event removes product from list
- Test search event filters products correctly
- Mock ProductRepository
```

### Create Widget Tests

**Prompt:**
```
Create widget tests for ProductListPage in test/widget/pages/product_list_page_test.dart:
- Test displays loading indicator when state is loading
- Test displays ListView when state is loaded with products
- Test displays empty state when no products
- Test displays error message when state is error
- Test tapping product card navigates to detail page
- Test pull-to-refresh triggers refresh event
- Mock ProductBloc using MockBloc
```

---

## Debugging

### Debug BLoC State Transitions

**Prompt:**
```
Add BlocObserver to log all BLoC events and state transitions for debugging:
- Log event type and details
- Log previous state
- Log new state
- Log errors with stack traces
- Use in debug mode only
```

### Debug Network Requests

**Prompt:**
```
Add Dio LogInterceptor to log all network requests:
- Log request method, URL, headers
- Log request body
- Log response status code
- Log response body
- Log errors
- Pretty print JSON
- Use in debug mode only
```

### Add Error Boundary

**Prompt:**
```
Create an ErrorBoundary widget that:
- Catches Flutter errors
- Displays user-friendly error screen
- Shows error details in debug mode
- Has retry button
- Logs errors to crash reporting service
```

---

## Refactoring

### Extract Reusable Widget

**Prompt:**
```
Extract the loading indicator pattern into a reusable LoadingWidget in lib/ui/widgets/loading_widget.dart that:
- Shows CircularProgressIndicator by default
- Can take custom size parameter
- Can take custom color parameter
- Can show optional loading message below indicator
```

### Create Base Repository

**Prompt:**
```
Create a BaseRepository abstract class in lib/data/repositories/base_repository.dart with:
- Common error handling method
- Generic cache management methods
- Network connectivity check
- Retry logic for failed requests
Make ProductRepositoryImpl extend BaseRepository
```

### Extract Constants

**Prompt:**
```
Create constants.dart in lib/core/ and move all hardcoded values:
- API endpoints
- Timeout durations
- Cache expiration times
- Animation durations
- Default values
Update all files to use these constants
```

---

## Migration and Updates

### Migrate to New Freezed Syntax

**Prompt:**
```
Update all Freezed classes from old syntax to new syntax:
- Remove abstract keyword
- Use new union syntax with sealed classes (if Dart supports)
- Update all .freezed.dart imports
- Re-run build_runner
```

### Update Dependencies

**Prompt:**
```
Check for breaking changes when updating to:
- Flutter 3.x
- Dart 3.x
- flutter_bloc 9.x
- freezed 2.x
Update code to handle:
- Null safety improvements
- API changes
- Deprecated features
```

### Add Internationalization

**Prompt:**
```
Add i18n support to ProductListPage:
- Extract all hardcoded strings
- Add to lib/l10n/intl_en.arb
- Add translations
- Use S.of(context).key pattern
- Regenerate localization files
```

---

## Advanced Patterns

### Implement Offline First

**Prompt:**
```
Update ProductRepository to implement offline-first pattern:
- Return cached data immediately
- Fetch from API in background
- Update cache with fresh data
- Emit stream updates when data changes
- Handle conflicts between local and remote data
```

### Add Optimistic Updates

**Prompt:**
```
Update ProductBloc to implement optimistic updates:
- Immediately update UI when user creates/updates/deletes
- Show operation in progress
- Revert changes if API call fails
- Show error message
- Provide retry option
```

### Implement Infinite Scroll

**Prompt:**
```
Update ProductListPage to implement infinite scroll:
- Detect when scrolled to bottom
- Load next page automatically
- Show loading indicator at bottom
- Handle end of list
- Support pull-to-refresh
- Cache loaded pages
```

### Add Real-time Updates

**Prompt:**
```
Implement WebSocket connection for real-time product updates:
- Connect to WebSocket server
- Listen for product created/updated/deleted events
- Update ProductBloc state automatically
- Show notification to user
- Handle connection errors and reconnection
```

---

## Performance Optimization

### Optimize List Rendering

**Prompt:**
```
Optimize ProductListPage for large lists:
- Use ListView.builder with const constructors
- Implement item key for list items
- Use cached network images
- Lazy load images
- Add pagination
```

### Reduce BLoC Rebuilds

**Prompt:**
```
Optimize ProductDetailPage BLoC usage:
- Use BlocSelector to rebuild only when specific data changes
- Use buildWhen to prevent unnecessary rebuilds
- Extract static widgets into const constructors
- Use BlocListener for side effects only
```

---

## Tips for Using These Prompts

1. **Be Specific**: Modify prompts to match your exact requirements
2. **Provide Context**: Include relevant file paths and class names
3. **Iterate**: Refine the generated code and ask for improvements
4. **Review**: Always review generated code for quality and correctness
5. **Test**: Run tests after generating code to ensure it works
6. **Follow Patterns**: Generated code should match existing project patterns

## Using Copilot CLI

```bash
# Explain code
gh copilot explain "What does this BLoC do?"

# Suggest commands
gh copilot suggest "How to run code generation for Freezed"

# Generate code
gh copilot suggest "Create a new API service for orders"
```

## Best Practices for Prompts

- ✅ Be explicit about file paths and locations
- ✅ Specify exact field names and types
- ✅ Mention required patterns (freezed, json_serializable)
- ✅ Request error handling explicitly
- ✅ Ask for tests when creating business logic
- ✅ Reference existing code for consistency
- ❌ Don't be too vague ("create a model")
- ❌ Don't forget to mention dependencies
- ❌ Don't skip architecture requirements

---

**Last Updated**: 2026-02-06  
**Compatible With**: Flutter 3.5.0+, Dart 3.5.0+

Use these prompts as starting points and adapt them to your specific needs. Happy coding with Copilot! 🚀

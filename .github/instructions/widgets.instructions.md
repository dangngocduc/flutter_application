# Widgets and UI Instructions

## Overview

This file provides comprehensive guidelines for building UI components in this Flutter application using BLoC pattern for state management, following Clean Architecture principles and Flutter best practices.

## Widget Structure

### Directory Organization

```
lib/ui/
├── blocs/              # BLoC state management
│   ├── auth/
│   │   ├── auth_bloc.dart
│   │   ├── auth_state.dart
│   │   └── auth_state.freezed.dart
│   └── blocs.dart      # Barrel file
├── pages/              # Full-screen pages
│   ├── authentication/
│   │   ├── signin/
│   │   │   ├── sign_in_page.dart
│   │   │   └── signin.dart
│   │   └── authentication.dart
│   └── pages.dart      # Barrel file
└── widgets/            # Reusable components
    ├── design_system/  # Design system components
    └── widgets.dart    # Barrel file
```

## Widget Types and When to Use Them

### 1. StatelessWidget (Preferred)

**Use when:**
- Widget doesn't manage its own state
- All data comes from constructor parameters
- State is managed by BLoC or parent widget
- Pure presentation logic

**Pattern:**
```dart
class UserProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback? onTap;
  
  const UserProfileCard({
    Key? key,
    required this.name,
    required this.email,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(email),
        onTap: onTap,
      ),
    );
  }
}
```

### 2. StatefulWidget

**Use only when:**
- Managing local UI state (e.g., text field input, animation controllers)
- NOT for business logic state (use BLoC instead)
- Form state, scroll controllers, animation controllers

**Pattern:**
```dart
class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  
  const AnimatedButton({
    Key? key,
    required this.onPressed,
    required this.label,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(_controller),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
```

## BLoC Integration Patterns

### 1. BlocProvider - Providing BLoC to Widget Tree

**Single BLoC:**
```dart
class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: SignInView(),
    );
  }
}
```

**Multiple BLoCs:**
```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => ProfileBloc()),
      ],
      child: HomeView(),
    );
  }
}
```

**Using GetIt (Dependency Injection):**
```dart
class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: SignInView(),
    );
  }
}
```

### 2. BlocBuilder - Building UI Based on State

**Basic usage:**
```dart
class SignInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return state.when(
          initial: () => _buildInitialView(),
          loading: () => _buildLoadingView(),
          authorized: (profile) => _buildAuthorizedView(profile),
          unAuthorized: () => _buildLoginForm(),
          error: (message) => _buildErrorView(message),
        );
      },
    );
  }
  
  Widget _buildInitialView() => SizedBox.shrink();
  Widget _buildLoadingView() => Center(child: CircularProgressIndicator());
  Widget _buildAuthorizedView(ProfileDto profile) => HomeScreen();
  Widget _buildLoginForm() => SignInForm();
  Widget _buildErrorView(String message) => ErrorWidget(message: message);
}
```

**With buildWhen (optimization):**
```dart
BlocBuilder<AuthBloc, AuthState>(
  buildWhen: (previous, current) {
    // Only rebuild when state changes from/to authorized
    return previous is! AuthStateAuthorized || current is AuthStateAuthorized;
  },
  builder: (context, state) {
    // Build UI
  },
)
```

### 3. BlocListener - Side Effects (Navigation, Snackbars, Dialogs)

**For side effects only (no UI changes):**
```dart
class SignInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          authorized: (profile) {
            // Navigate to home
            Navigator.of(context).pushReplacementNamed('/home');
          },
          unAuthorized: () {},
          error: (message) {
            // Show error snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
        );
      },
      child: _buildContent(),
    );
  }
}
```

**With listenWhen (optimization):**
```dart
BlocListener<AuthBloc, AuthState>(
  listenWhen: (previous, current) {
    // Only listen when transitioning to error state
    return current is AuthStateError;
  },
  listener: (context, state) {
    if (state is AuthStateError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: _buildContent(),
)
```

### 4. BlocConsumer - Combine Builder and Listener

**When you need both UI updates and side effects:**
```dart
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    // Handle side effects
    state.whenOrNull(
      authorized: (profile) => Navigator.of(context).pushReplacementNamed('/home'),
      error: (message) => _showErrorDialog(context, message),
    );
  },
  builder: (context, state) {
    // Build UI
    return state.when(
      initial: () => _buildInitial(),
      loading: () => _buildLoading(),
      authorized: (profile) => _buildSuccess(profile),
      unAuthorized: () => _buildLoginForm(),
      error: (message) => _buildError(message),
    );
  },
)
```

## Accessing BLoC from Widgets

### Reading BLoC

```dart
// Get BLoC instance
final authBloc = context.read<AuthBloc>();

// Dispatch event
authBloc.add(AuthEvent.login(username, password));

// Or inline
context.read<AuthBloc>().add(LoginEvent(username, password));
```

### Watching State

```dart
// In build method only
final authState = context.watch<AuthBloc>().state;
```

### Selecting Specific State

```dart
// Only rebuild when specific part of state changes
final isLoading = context.select<AuthBloc, bool>(
  (bloc) => bloc.state is AuthStateLoading,
);
```

## Widget Composition Patterns

### 1. Extract Reusable Components

**Bad - Monolithic Widget:**
```dart
class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 100+ lines of UI code
        ],
      ),
    );
  }
}
```

**Good - Composed Widgets:**
```dart
class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SignInHeader(),
          SignInForm(),
          SignInFooter(),
        ],
      ),
    );
  }
}

class SignInHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Header UI
    );
  }
}

class SignInForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Form(
      // Form UI
    );
  }
}
```

### 2. Builder Methods (for small, non-reusable widgets)

```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          _buildContent(context),
          _buildFooter(context),
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      // Small, page-specific header
    );
  }
  
  Widget _buildContent(BuildContext context) {
    return Expanded(
      // Content
    );
  }
  
  Widget _buildFooter(BuildContext context) {
    return Container(
      // Small, page-specific footer
    );
  }
}
```

### 3. Conditional Rendering

```dart
// Using null safety
Widget? optionalWidget = condition ? MyWidget() : null;

// Using if-else in children
children: [
  if (showHeader) HeaderWidget(),
  ContentWidget(),
  if (showFooter) FooterWidget(),
],

// Using ternary
child: isLoading 
    ? CircularProgressIndicator() 
    : ContentWidget(),

// Using state pattern matching
state.when(
  loading: () => LoadingWidget(),
  success: (data) => DataWidget(data),
  error: (message) => ErrorWidget(message),
),
```

## Using Context Extensions

This project includes helpful context extensions in `lib/utils/`:

```dart
// Access theme
final theme = context.theme;
final textTheme = context.textTheme;
final colorScheme = context.colorScheme;

// Access media query
final size = context.size;
final mediaQuery = context.mediaQueryData;

// Example usage
Text(
  'Hello',
  style: context.textTheme.headlineMedium,
)

Container(
  width: context.size.width * 0.8,
  color: context.colorScheme.primary,
)
```

## Forms and Input Handling

### Form Pattern with BLoC

```dart
class SignInForm extends StatefulWidget {
  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthEvent.login(
          _usernameController.text,
          _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Username'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter username';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthStateLoading;
              
              return ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text('Sign In'),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## List and Grid Patterns

### List with BLoC

```dart
class UserListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return state.when(
          initial: () => SizedBox.shrink(),
          loading: () => Center(child: CircularProgressIndicator()),
          loaded: (users) => ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserListItem(user: user);
            },
          ),
          error: (message) => Center(child: Text('Error: $message')),
        );
      },
    );
  }
}
```

### Separated List

```dart
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (context, index) => Divider(),
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)
```

### Grid View

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 0.75,
  ),
  itemCount: products.length,
  itemBuilder: (context, index) {
    return ProductCard(product: products[index]);
  },
)
```

## Navigation Patterns

### Simple Navigation

```dart
// Push
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => DetailPage()),
);

// Push named route
Navigator.of(context).pushNamed('/detail', arguments: userId);

// Replace
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => HomePage()),
);

// Pop
Navigator.of(context).pop();

// Pop with result
Navigator.of(context).pop(result);
```

### Navigation with BLoC Side Effects

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    state.whenOrNull(
      authorized: (profile) {
        Navigator.of(context).pushReplacementNamed('/home');
      },
      unAuthorized: () {
        Navigator.of(context).pushReplacementNamed('/login');
      },
    );
  },
  child: child,
)
```

### Passing Data Between Screens

```dart
// Sending data
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => DetailPage(userId: user.id),
  ),
);

// Receiving data in constructor
class DetailPage extends StatelessWidget {
  final String userId;
  
  const DetailPage({Key? key, required this.userId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Use userId
  }
}
```

## Loading States and Error Handling

### Loading Indicators

```dart
// Full screen loading
state is LoadingState 
  ? Center(child: CircularProgressIndicator())
  : ContentWidget()

// Loading overlay
Stack(
  children: [
    ContentWidget(),
    if (isLoading)
      Container(
        color: Colors.black54,
        child: Center(child: CircularProgressIndicator()),
      ),
  ],
)

// Button loading state
ElevatedButton(
  onPressed: isLoading ? null : _handleSubmit,
  child: isLoading
      ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : Text('Submit'),
)
```

### Error Display

```dart
// Error widget
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorView({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
```

### Snackbars and Toasts

```dart
// Simple snackbar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Action completed')),
);

// Snackbar with action
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Item deleted'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Undo action
      },
    ),
  ),
);

// Custom snackbar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Expanded(child: Text('Success!')),
      ],
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 2),
  ),
);
```

## Dialogs and Bottom Sheets

### Dialog

```dart
void _showConfirmDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirm'),
      content: Text('Are you sure?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Confirm'),
        ),
      ],
    ),
  ).then((confirmed) {
    if (confirmed == true) {
      // Handle confirmation
    }
  });
}
```

### Bottom Sheet

```dart
void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Handle share
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                // Handle delete
              },
            ),
          ],
        ),
      );
    },
  );
}
```

## Performance Optimization

### 1. Use const Constructors

```dart
// Good - const widget won't rebuild
const Text('Hello'),
const SizedBox(height: 16),
const Icon(Icons.home),

// Bad - will rebuild unnecessarily
Text('Hello'),
SizedBox(height: 16),
Icon(Icons.home),
```

### 2. Extract Static Widgets

```dart
class MyPage extends StatelessWidget {
  static const _header = Text('Header'); // Won't rebuild
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header,
        DynamicContent(),
      ],
    );
  }
}
```

### 3. Use Keys for Lists

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(
      key: ValueKey(items[index].id), // Important for list updates
      item: items[index],
    );
  },
)
```

### 4. Optimize BLoC Rebuilds

```dart
// Use buildWhen
BlocBuilder<MyBloc, MyState>(
  buildWhen: (previous, current) => previous.data != current.data,
  builder: (context, state) => MyWidget(state.data),
)

// Use select for specific fields
final userName = context.select((UserBloc bloc) => bloc.state.user?.name);
```

## Widget Testing Patterns

```dart
testWidgets('should display user name', (WidgetTester tester) async {
  // Arrange
  final user = UserDto(id: '1', name: 'John', email: 'john@test.com');
  
  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: UserProfileCard(
        name: user.name,
        email: user.email,
      ),
    ),
  );
  
  // Assert
  expect(find.text('John'), findsOneWidget);
  expect(find.text('john@test.com'), findsOneWidget);
});
```

## Copilot Prompts for Widgets

**Generate a page with BLoC:**
> "Create a ProductListPage that uses ProductBloc with BlocBuilder to display a list of products"

**Generate a reusable widget:**
> "Create a CustomButton widget with text, icon, loading state, and onPressed callback"

**Generate a form:**
> "Create a UserProfileForm with name, email, and phone fields using TextFormField with validation"

**Add navigation:**
> "Add navigation from SignInPage to HomePage when AuthState is authorized"

---

**Last Updated**: 2026-02-06

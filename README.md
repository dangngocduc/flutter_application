# flutter_application

## Structure
- data
    - __blocs__: Bloc on this applocation
    - __datasources__: Data provider
    - __models__: Model Data 
    - __repositories__: list of repository
- __pages__: Screen, Page of Application
- __utils__
- __widgets__: Component reuse on this app
- __application.dart__: MaterialApp of this app
- __main.dart__

## Extension
__path: lib/utils/extensions.dart__

### BuildContext
```
extension StateExtensions on State {
  ThemeData get theme => Theme.of(context);

  TextTheme get textTheme => Theme.of(context).textTheme;

  TextTheme get primaryTextTheme => Theme.of(context).primaryTextTheme;

  TextTheme get accentTextTheme => Theme.of(context).accentTextTheme;

  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  MediaQueryData get mediaQueryData => MediaQuery.of(context);

  Size get size => MediaQuery.of(context).size;
}
```
### State
```
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;

  TextTheme get accentTextTheme => Theme.of(this).accentTextTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  MediaQueryData get mediaQueryData => MediaQuery.of(this);

  Size get size => MediaQuery.of(this).size;
}
```
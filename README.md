# flutter_application

## Structure
- assets
  - icons: start with ic_ 
  - images: start with image_
- lib 
    - __data__
        - _blocs_: Bloc on this applocation
        - _datasources_: Data provider
        - _models_: Model Data, suffix: *_model*
        - _repositories_: list of repository
    - __gen__: Gen Assets Management
    - __pages__: Screen, Page of Application, suffix: *_page*
    - __utils__
    - __widgets__: Component reuse on this app, suffix: *_widget*
    - __application.dart__: MaterialApp of this app
    - __main.dart__


## Resource Manager
```
https://pub.dev/packages/flutter_gen
```
### Homebrew
Works with MacOS and Linux.
```sh
$ brew install FlutterGen/tap/fluttergen
```
### Pub Global
Works with MacOS, Linux and Windows.
```sh
$ dart pub global activate flutter_gen
```
### Generate Model and State
```sh
$ flutter pub run build_runner build
```

## Extension
_path: lib/utils/extensions.dart_

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

## CI/CD 
__This project is config CI/CD with Github Action and build release only for Android.__

Work flow:
```
.github/workflows/dart.yml
```
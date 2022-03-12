# flutter_application

This template base on Flutter 2.10.3

## Structure
- assets
  - icons: start with ic_ 
  - images: start with image_
- lib 
    - __data__
        - _datasource_: Data provider
            - local : 
            - remote : API service 
        - _dto_: Model Data, suffix: *_dto*
        - _repositories_: implement of repository interface on domain layer
    - __gen__: Gen Assets Management
    - __domain__
        - __entity__: Model interface, suffix: *_model*
        - __repository__: repository interface
    - __ui__    
        - _blocs_: Bloc on this application
        - __pages__: Screen, Page of Application, suffix: *_page*
        - __widgets__: Component reuse on this app, suffix: *_widget*
    - __utils__
    - __application.dart__: MaterialApp of this app
    - __initialize_dependencies.dart__: init dependencies global as local service, bloc, domain repository
    - __main.dart__

## Dependencies
Init all dependencies global on  `initialize_dependencies.dart`

example: `LocalService`, `Repository_` of domain layer.
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

## Utils
### Generate quick import file for a folder
1, Edit path of folder need gen quick import
```
# Change Folder At Here
genQuickImport lib/domain

```
2,
run shell `gen_quick_import.sh`
```
 bash gen_quick_import.sh
```
### Generate Model
```
 bash gen.sh
```

## Release App 
### Change Icon App

Update icon : _assets/images/icon_app.png_

run:
```
[fvm] flutter pub run flutter_launcher_icons:main
```

## Change splash Page on Native 

(https://pub.dev/packages/flutter_native_splash)

[fvm] flutter pub run flutter_native_splash:create --path=flutter_native_splash.yaml
## CI/CD 
__This project is config CI/CD with Github Action and build release only for Android.__

Work flow:
```
.github/workflows/dart.yml
```
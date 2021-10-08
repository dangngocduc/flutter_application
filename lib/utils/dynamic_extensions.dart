import 'my_utils.dart';

extension DynamicUtils on dynamic {
  @Deprecated('isNull is deprecated and cannot be used, use "==" operator')
  bool get isNull => MyUtils.isNull(this);

  bool? get isBlank => MyUtils.isBlank(this);

  @Deprecated(
      'isNullOrBlank is deprecated and cannot be used, use "isBlank" instead')
  bool? get isNullOrBlank => MyUtils.isNullOrBlank(this);

  void printError(
      {String info = '', Function logFunction = MyUtils.printFunction}) =>
      // ignore: unnecessary_this
  logFunction('Error: ${this.runtimeType}', this, info, isError: true);

  void printInfo(
      {String info = '',
        Function printFunction = MyUtils.printFunction}) =>
      // ignore: unnecessary_this
  printFunction('Info: ${this.runtimeType}', this, info);
}
import 'dart:math';

extension DoubleExtension on double {
  ///
  /// Example : convert 2.36 -> 2.4 toPrecision(1)
  ///
  double toPrecision(int fractionDigits) {
    var mod = pow(10, fractionDigits.toDouble()).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }
}
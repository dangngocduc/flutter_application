
typedef ValueBuilderFromValue<R, F> = R Function(F data);

typedef ValueBuilder<R> = R Function();

extension AppListExtension<T> on Iterable<T> {
  /// The same with join() but use for Widget
  List<R> joinMap<R>(
      ValueBuilder separator, ValueBuilderFromValue<R, T> itemBuilder) {
    Iterator<T> iterator = this.iterator;
    if (!iterator.moveNext()) return [];
    List<R> results = [];
    results.add(itemBuilder(iterator.current));
    while (iterator.moveNext()) {
      results.add(separator());
      results.add(itemBuilder(iterator.current));
    }
    return results;
  }
}

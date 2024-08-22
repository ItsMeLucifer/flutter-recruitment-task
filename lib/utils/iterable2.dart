extension Iterable2<T> on Iterable<T> {
  T? reduceOrNull(T Function(T, T) combine) {
    if (isEmpty) {
      return null;
    }

    return reduce(combine);
  }
}

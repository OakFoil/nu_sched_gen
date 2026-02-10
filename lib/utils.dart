extension NullUtils<T> on T? {
  String get toStringOrDash => this == null ? "-" : toString();
}

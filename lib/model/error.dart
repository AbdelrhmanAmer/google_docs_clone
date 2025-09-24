class ErrorModel<T> {
  final String? error;
  final T? data;
  ErrorModel({
    required this.error,
    required this.data,
  });
}

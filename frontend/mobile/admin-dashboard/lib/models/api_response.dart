class ApiResponse<T> {
  final bool success;
  final T data;
  final String message;

  ApiResponse({
    required this.success,
    required this.data,
    required this.message,
  });
}

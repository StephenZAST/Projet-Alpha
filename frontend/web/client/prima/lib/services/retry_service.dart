class RetryService {
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts == maxAttempts) rethrow;
        await Future.delayed(delay * attempts);
      }
    }
    throw Exception('Maximum retry attempts reached');
  }
}

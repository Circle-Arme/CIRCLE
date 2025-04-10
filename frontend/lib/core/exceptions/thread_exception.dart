class ThreadException implements Exception {
  final String message;

  ThreadException(this.message);

  @override
  String toString() => message;
}
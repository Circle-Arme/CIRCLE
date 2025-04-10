class CommunityException implements Exception {
  final String message;

  CommunityException(this.message);

  @override
  String toString() => message;
}
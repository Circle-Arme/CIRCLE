// models/thread_model.dart
class ThreadModel {
  final String id;
  final String title;
  final String creatorName;
  final DateTime createdAt;
  final int repliesCount;
  final String classification;
  final String content;         // محتوى الموضوع
  final List<String> tags;      // قائمة الوسوم

  ThreadModel({
    required this.id,
    required this.title,
    required this.creatorName,
    required this.createdAt,
    required this.repliesCount,
    required this.classification,
    required this.content,
    required this.tags,
  });
}

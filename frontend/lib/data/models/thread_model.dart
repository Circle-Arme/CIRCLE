class ThreadModel {
  final String id;
  final String title;
  final String creatorName;
  final DateTime createdAt;
  final int repliesCount;
  final String classification; // Q&A, General, etc.
  final String content;        // محتوى الثريد
  final List<String> tags;     // وسوم الموضوع
  final String communityId;    // معرف المجتمع
  final bool isJobOpportunity; // هل الثريد خاص بفرص العمل

  const ThreadModel({
    required this.id,
    required this.title,
    required this.creatorName,
    required this.createdAt,
    required this.repliesCount,
    required this.classification,
    required this.content,
    required this.tags,
    required this.communityId,
    required this.isJobOpportunity,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) {
    return ThreadModel(
      id: json['id'] as String,
      title: json['title'] as String,
      creatorName: json['creator_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      repliesCount: json['replies_count'] as int,
      classification: json['classification'] as String,
      content: json['content'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      communityId: json['community_id'] as String,
      isJobOpportunity: json['is_job_opportunity'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'creator_name': creatorName,
      'created_at': createdAt.toIso8601String(),
      'replies_count': repliesCount,
      'classification': classification,
      'content': content,
      'tags': tags,
      'community_id': communityId,
      'is_job_opportunity': isJobOpportunity,
    };
  }
}
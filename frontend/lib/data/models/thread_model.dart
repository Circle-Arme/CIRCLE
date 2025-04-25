// lib/data/models/thread_model.dart

import 'package:flutter/foundation.dart';

///────────────────────────────────────────
/// الموديل المسطّح للردود (ReplyModel)
class ReplyModel {
  final String id;
  final String text;
  final String creatorName;
  final DateTime createdAt;
  final String creatorId;
  final String? file;
  final int likesCount;      // ← جديد: عدّاد الإعجابات
  final bool isPromoted;     // ← جديد: حالة الترويج (رفع الرد)


  ReplyModel({
    required this.id,
    required this.text,
    required this.creatorName,
    required this.createdAt,
    required this.creatorId,
    this.file,
    required this.likesCount,
    required this.isPromoted,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) => ReplyModel(
    id: (json['id'] ?? '').toString(),
    text: json['reply_text'] as String? ?? '',
    creatorName: json['creator_name'] as String? ?? 'مجهول',
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
    creatorId: (json['created_by'] ?? '').toString(),
    file: json['file'] as String?,
    likesCount: json['likes_count'] as int? ?? 0,
    isPromoted: json['is_promoted'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'reply_text': text,
    'creator_name': creatorName,
    'created_at': createdAt.toIso8601String(),
    'created_by': creatorId,
    'file': file,
    'likes_count': likesCount,
    'is_promoted': isPromoted,
  };
}

///────────────────────────────────────────
/// الموديل الشجري للردود (ApiReply)
class ApiReply {
  final String id;
  final String text;
  final DateTime createdAt;
  final String creatorName;
  final String creatorId;
  final String? file;
  final int likesCount;      // ← جديد: عدّاد الإعجابات
  final bool isPromoted;     // ← جديد: حالة الترويج
  final List<ApiReply> children;
  final bool isLiked;

  ApiReply({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.creatorName,
    required this.creatorId,
    this.file,
    required this.likesCount,
    required this.isPromoted,
    this.children = const [],
    required this.isLiked,
  });

  factory ApiReply.fromJson(Map<String, dynamic> json) => ApiReply(
    id: json['id'].toString(),
    text: json['reply_text'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at']),
    creatorName: json['creator_name'] as String? ?? 'مجهول',
    creatorId: json['created_by']?.toString() ?? '',
    file: json['file'] as String?,
    likesCount: json['likes_count'] as int? ?? 0,
    isPromoted: json['is_promoted'] as bool? ?? false,
    isLiked:    json['liked_by_me'] as bool? ?? false,
    children: (json['children'] as List<dynamic>? ?? [])
        .map((c) => ApiReply.fromJson(c as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'reply_text': text,
    'created_at': createdAt.toIso8601String(),
    'creator_name': creatorName,
    'created_by': creatorId,
    'file': file,
    'likes_count': likesCount,
    'is_promoted': isPromoted,
    'children': children.map((c) => c.toJson()).toList(),
  };
}

///────────────────────────────────────────
/// الموديل الرئيسي للثريد (ThreadModel)
class ThreadModel {
  final String id;
  final String title;
  final String creatorName;
  final String creatorId;
  final DateTime createdAt;
  final int repliesCount;
  final String classification;
  final String details;
  final List<String> tags;
  final String communityId;
  final bool isJobOpportunity;
  final int likesCount;
  final bool likedByMe;
  final String? fileAttachment;

  /// الردود المسطّحة
  final List<ReplyModel> replies;

  /// الردود المتداخلة (شجرة)
  final List<ApiReply> repliesTree;

  ThreadModel({
    required this.id,
    required this.title,
    required this.creatorName,
    required this.creatorId,
    required this.createdAt,
    required this.repliesCount,
    required this.classification,
    required this.details,
    required this.tags,
    required this.communityId,
    required this.isJobOpportunity,
    required this.likesCount,
    required this.likedByMe,
    this.fileAttachment,
    required this.replies,
    required this.repliesTree,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) => ThreadModel(
    id: (json['id'] ?? '').toString(),
    title: json['title'] as String? ?? '',
    creatorName: json['creator_name'] as String? ?? '',
    creatorId: (json['created_by'] ?? '').toString(),
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
    repliesCount: json['replies_count'] as int? ?? 0,
    classification: json['classification'] as String? ?? '',
    details: json['details'] as String? ?? '',
    tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
    communityId:
    (json['community_id'] ?? json['community'] ?? '').toString(),
    isJobOpportunity: json['is_job_opportunity'] as bool? ?? false,
    likesCount: json['likes_count'] as int? ?? 0,
    likedByMe:     json['liked_by_me'] as bool? ?? false,
    fileAttachment: json['file_attachment'] as String?,
    replies: (json['replies'] as List<dynamic>? ?? [])
        .map((r) => ReplyModel.fromJson(r as Map<String, dynamic>))
        .toList(),
    repliesTree: (json['replies_tree'] as List<dynamic>? ?? [])
        .map((r) => ApiReply.fromJson(r as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'creator_name': creatorName,
    'created_by': creatorId,
    'created_at': createdAt.toIso8601String(),
    'replies_count': repliesCount,
    'classification': classification,
    'details': details,
    'tags': tags,
    'community_id': communityId,
    'is_job_opportunity': isJobOpportunity,
    'likes_count': likesCount,
    'file_attachment': fileAttachment,
    'replies': replies.map((r) => r.toJson()).toList(),
    'replies_tree': repliesTree.map((r) => r.toJson()).toList(),
  };
}

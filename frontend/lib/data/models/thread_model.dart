// lib/data/models/thread_model.dart


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
  final bool likedByMe;

  ReplyModel({
    required this.id,
    required this.text,
    required this.creatorName,
    required this.createdAt,
    required this.creatorId,
    this.file,
    required this.likesCount,
    required this.isPromoted,
    this.likedByMe = false,
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
    likedByMe: json['liked_by_me'] ?? false,
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

// api_reply.dart

class ApiReply {
  final String id;
  final String text;
  final DateTime createdAt;
  final String creatorName;
  final String creatorId;
  final String? file;
  final int likesCount;
  final bool isPromoted;
  final bool isLiked;
  final List<ApiReply> children;

  /// مقتطف من الردّ الأب (إن وُجد)
  final ParentSnippet? parentSnippet;

  ApiReply({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.creatorName,
    required this.creatorId,
    this.file,
    required this.likesCount,
    required this.isPromoted,
    required this.isLiked,
    this.children = const [],
    this.parentSnippet,
  });

  factory ApiReply.fromJson(Map<String, dynamic> json) {
    // أولًا: الأطفال
    final kids = (json['children'] as List<dynamic>? ?? [])
        .map((c) => ApiReply.fromJson(c as Map<String, dynamic>))
        .toList();

    // ثم مقتطف الأبّ، إذا وُجد
    ParentSnippet? snippet;
    if (json['parent_snippet'] != null) {
      snippet = ParentSnippet.fromJson(
          json['parent_snippet'] as Map<String, dynamic>);
    }

    return ApiReply(
      id:            json['id'].toString(),
      text:          json['reply_text'] as String? ?? '',
      createdAt:     DateTime.parse(json['created_at'] as String),
      creatorName:   json['creator_name'] as String? ?? 'مجهول',
      creatorId:     json['created_by']?.toString() ?? '',
      file:          json['file'] as String?,
      likesCount:    json['likes_count'] as int? ?? 0,
      isPromoted:    json['is_promoted'] as bool? ?? false,
      isLiked:       json['liked_by_me'] as bool? ?? false,
      children:      kids,
      parentSnippet: snippet,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':             id,
    'reply_text':     text,
    'created_at':     createdAt.toIso8601String(),
    'creator_name':   creatorName,
    'created_by':     creatorId,
    'file':           file,
    'likes_count':    likesCount,
    'is_promoted':    isPromoted,
    'liked_by_me':    isLiked,
    'children':       children.map((c) => c.toJson()).toList(),
    'parent_snippet': parentSnippet?.toJson(),
  };
}

/// مقتطف مُختصر من الردّ الأب لعرضه داخل فقاعة الاقتباس
class ParentSnippet {
  final String id;
  final String text;
  final String creatorName;
  final String creatorId;
  final String? file;

  ParentSnippet({
    required this.id,
    required this.text,
    required this.creatorName,
    required this.creatorId,
    this.file,
  });

  factory ParentSnippet.fromJson(Map<String, dynamic> json) {
    return ParentSnippet(
      id:          json['id'].toString(),
      text:        json['text'] as String? ?? '',
      creatorName: json['creator_name'] as String? ?? 'مجهول',
      creatorId:   json['creator_id']?.toString() ?? '',
      file:        json['file'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'text':          text,
    'creator_name':  creatorName,
    'creator_id':    creatorId,
    'file':          file,
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
  String? get fileAttachmentName =>
      fileAttachment?.split('/').last;

  /// الردود المسطّحة
  final List<ReplyModel> replies;

  /// الردود المتداخلة (شجرة)
  final List<ApiReply> repliesTree;
  final String? jobType;
  final String? location;
  final String? salary;
  final String? jobLink;
  final String? jobLinkType;

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
    this.jobType,
    this.location,
    this.salary,
    this.jobLink,
    this.jobLinkType,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) => ThreadModel(
    id: (json['id'] ?? '').toString(),
    title: json['title'] as String? ?? '',
    creatorName: json['creator_name'] as String? ?? '',
    creatorId: (json['created_by'] ?? '').toString(),
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    repliesCount: json['replies_count'] as int? ?? 0,
    classification: json['classification'] as String? ?? '',
    details: json['details'] as String? ?? '',
    tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
    communityId: (json['community_id'] ?? json['community'] ?? '').toString(),
    isJobOpportunity: json['is_job_opportunity'] as bool? ?? false,
    likesCount: json['likes_count'] as int? ?? 0,
    likedByMe: json['liked_by_me'] as bool? ?? false,
    fileAttachment: json['file_attachment'] as String?, // تصحيح الاسم ليتماشى مع الـ Backend
    replies: (json['replies'] as List<dynamic>? ?? [])
        .map((r) => ReplyModel.fromJson(r as Map<String, dynamic>))
        .toList(),
    repliesTree: (json['replies_tree'] as List<dynamic>? ?? [])
        .map((r) => ApiReply.fromJson(r as Map<String, dynamic>))
        .toList(),
    jobType: json['job_type'] as String?,
    location: json['location'] as String?,
    salary: json['salary'] as String?,
    jobLink: json['job_link'] as String?,
    jobLinkType: json['job_link_type'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'creator_name': creatorName,
    'created_by': creatorId,
    'created_at': createdAt.toIso8601String(),
    'replies_count': repliesCount,
    'classification': classification,
    'job_type': jobType,
    'location': location,
    'salary': salary,
    'job_link': jobLink,
    'job_link_type': jobLinkType,
    'details': details,
    'tags': tags,
    'community_id': communityId,
    'is_job_opportunity': isJobOpportunity,
    'likes_count': likesCount,
    'file_attachment': fileAttachment,
    'replies': replies.map((r) => r.toJson()).toList(),
    'replies_tree': repliesTree.map((r) => r.toJson()).toList(),
  };
  // ─────────────────────────── copyWith ───────────────────────────
  ThreadModel copyWith({
    String? title,
    String? details,
    String? classification,
    List<String>? tags,
    bool? isJobOpportunity,
    String? jobType,
    String? location,
    String? salary,
    String? jobLink,
    String? jobLinkType,
    int? likesCount,
    bool? likedByMe,
    int? repliesCount,
    List<ReplyModel>? replies,
    List<ApiReply>? repliesTree,
  }) {
    return ThreadModel(
      id: id,
      title: title ?? this.title,
      creatorName: creatorName,
      creatorId: creatorId,
      createdAt: createdAt,
      repliesCount: repliesCount ?? this.repliesCount,
      classification: classification ?? this.classification,
      details: details ?? this.details,
      tags: tags ?? this.tags,
      communityId: communityId,
      isJobOpportunity: isJobOpportunity ?? this.isJobOpportunity,
      likesCount: likesCount ?? this.likesCount,
      likedByMe: likedByMe ?? this.likedByMe,
      fileAttachment: fileAttachment,
      replies: replies ?? this.replies,
      repliesTree: repliesTree ?? this.repliesTree,
      jobType: jobType ?? this.jobType,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      jobLink: jobLink ?? this.jobLink,
      jobLinkType: jobLinkType ?? this.jobLinkType,
    );
  }


}


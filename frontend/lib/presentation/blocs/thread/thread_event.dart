import 'package:file_picker/file_picker.dart';
import 'package:frontend/data/models/thread_model.dart';

/// الأحداث الأساسية لتطبيق Thread
abstract class ThreadEvent {}

/// ─────────────────────────── Public Events ───────────────────────────

/// حدث لبدء الاتصال بالـ WebSocket
class StartRealtimeEvent extends ThreadEvent {
  final int? communityId;
  final String roomType;
  StartRealtimeEvent(this.communityId, this.roomType);
}

/// حدث لجلب قائمة الثريدات
class FetchThreadsEvent extends ThreadEvent {
  final int communityId;
  final String roomType;
  final bool isJobOpportunity;

  FetchThreadsEvent(
      this.communityId,
      this.roomType, {
        this.isJobOpportunity = false,
      });
}

/// حدث لإنشاء ثريد جديد
class CreateThreadEvent extends ThreadEvent {
  final int communityId;
  final String roomType;
  final String title;
  final String content;
  final String classification;
  final List<String> tags;
  final PlatformFile? file;
  final bool isJobOpportunity;
  final String? jobType;
  final String? location;
  final String? salary;
  final String? jobLink;
  final String? jobLinkType;

  CreateThreadEvent(
      this.communityId,
      this.roomType,
      this.title,
      this.content,
      this.classification,
      this.tags, {
        this.file,
        this.isJobOpportunity = false,
        this.jobType,
        this.location,
        this.salary,
        this.jobLink,
        this.jobLinkType,
      });
}

/// حدث لتحديث ثريد موجود
class UpdateThreadEvent extends ThreadEvent {
  final int threadId;
  final int communityId;
  final String roomType;
  final String title;
  final String content;
  final String classification;
  final List<String> tags;
  final PlatformFile? file;
  final bool isJobOpportunity;
  final String? jobType;
  final String? location;
  final String? salary;
  final String? jobLink;
  final String? jobLinkType;

  UpdateThreadEvent({
    required this.threadId,
    required this.communityId,
    required this.roomType,
    required this.title,
    required this.content,
    required this.classification,
    required this.tags,
    this.file,
    this.isJobOpportunity = false,
    this.jobType,
    this.location,
    this.salary,
    this.jobLink,
    this.jobLinkType,
  });
}

/// ─────────────────────────── Internal Events ───────────────────────────

/// حدث داخلي عند إضافة ثريد جديد
class ThreadAdded extends ThreadEvent {
  final ThreadModel thread;
  ThreadAdded(this.thread);
}

/// حدث داخلي عند حذف ثريد
class ThreadDeleted extends ThreadEvent {
  final String id;
  ThreadDeleted(this.id);
}

/// حدث داخلي عند تحديث ثريد
class ThreadUpdated extends ThreadEvent {
  final ThreadModel thread;
  ThreadUpdated(this.thread);
}

/// حدث داخلي عند تبديل حالة الإعجاب بثريد
class ThreadLikeToggled extends ThreadEvent {
  final String id;
  final int likes;
  final bool likedByMe;
  ThreadLikeToggled({
    required this.id,
    required this.likes,
    required this.likedByMe,
  });
}

/// حدث داخلي عند تغيير عدد الردود
class RepliesCountChanged extends ThreadEvent {
  final String threadId;
  final int replies;
  RepliesCountChanged({required this.threadId, required this.replies});
}

/// حدث داخلي عند إضافة رد جديد
class ReplyAdded extends ThreadEvent {
  final ReplyModel reply;
  ReplyAdded(this.reply);
}

/// حدث داخلي عند تبديل حالة الإعجاب برد
class ReplyLikeToggled extends ThreadEvent {
  final String id;
  final int likes;
  ReplyLikeToggled({required this.id, required this.likes});
}
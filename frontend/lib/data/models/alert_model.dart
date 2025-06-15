/// تعريف نموذج (Model) التنبيه Alert وكيفية التحويل من/إلى ‎JSON.
///
/// Author: Your Name – May 2025
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';

/// أنواع التنبيهات المسموح بها في الـ Backend.
/// استخدم enum لكتابة أوضح وأسهل في التعامل داخل الـ UI و Bloc.
enum AlertType { info, warn, job, reply, unknown }

AlertType _parseType(String? raw) {
  switch (raw) {
    case 'info':
      return AlertType.info;
    case 'warn':
      return AlertType.warn;
    case 'job':
      return AlertType.job;
    case 'reply':
      return AlertType.reply;
    default:
      return AlertType.unknown;
  }
}

/// نموذج البيانات النهائي – يمتد من Equatable لتسهيل المقارنة والنسخ.
class AlertModel extends Equatable {
  final int id;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final AlertType type;
  final int? objectId; // قد يكون thread_id أو غيره بحسب نوع التنبيه

  const AlertModel({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.objectId,
  });

  /// factory من JSON القادم من الـ API.
  factory AlertModel.fromJson(Map<String, dynamic> j) => AlertModel(
    id: j['id'] as int,
    message: j['message'] as String,
    createdAt: DateTime.parse(j['created_at'] as String),
    isRead: j['is_read'] as bool,
    type: _parseType(j['type'] as String?),
    objectId: j['object_id'] as int?,
  );

  /// تحويل AlertModel إلى JSON – مفيد للتخزين المؤقّت (Caching) إن احتجت.
  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'created_at': createdAt.toIso8601String(),
    'is_read': isRead,
    'type': type.name,
    'object_id': objectId,
  };

  /// نسخة معدّلة (immutability friendly).
  AlertModel copyWith({bool? isRead}) => AlertModel(
    id: id,
    message: message,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
    type: type,
    objectId: objectId,
  );

  @override
  List<Object?> get props => [id, message, createdAt, isRead, type, objectId];
}
